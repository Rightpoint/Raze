//
//  RZXEffectView.m
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXGLContext.h>
#import <RazeCore/RZXQuadMesh.h>
#import <RazeCore/RZXCamera.h>
#import <RazeCore/RZXGLContext.h>
#import <RazeUIKit/RZXEffectView.h>
#import <RazeUIKit/RZXViewTexture.h>

#define RZX_EFFECT_AUX_TEXTURES (RZX_EFFECT_MAX_DOWNSAMPLE + 1)

@interface RZXGLView (RZProtected)

- (void)createBuffers;
- (void)destroyBuffers;

@end

@interface RZXEffectView ()

@property (nonatomic, readonly) RZXGLContext *context;

@property (strong, nonatomic) RZXCamera *effectCamera;

@property (strong, nonatomic) IBOutlet UIView *sourceView;
@property (strong, nonatomic) RZXViewTexture *viewTexture;

@property (assign, nonatomic) BOOL textureLoaded;

@end

@implementation RZXEffectView {
    GLuint _fbos[2];
    GLuint _drbs[2];

    GLuint _auxTex[2][RZX_EFFECT_AUX_TEXTURES];
}

#pragma mark - lifecycle

- (instancetype)initWithSourceView:(UIView *)view effect:(RZXEffect *)effect dynamicContent:(BOOL)dynamic
{
    self = [super initWithFrame:view.bounds];
    if ( self ) {
        self.dynamic = dynamic;
        self.effect = effect;
        self.sourceView = view;
    }
    return self;
}

#pragma mark - public methods

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    [self updateCamera];

    if ( self.viewTexture != nil ) {
        [self createTexture];
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];

    [self updateCamera];

    if ( self.viewTexture != nil ) {
        [self createTexture];
    }
}

- (void)setMultisampleLevel:(GLsizei)multisampleLevel
{
    // no-op, RZXEffectView doesn't support multisample antialiasing
}

- (void)setEffect:(RZXEffect *)effect
{
    _effect = effect;
    self.model = [RZXQuadMesh quadWithSubdivisionLevel:effect.preferredLevelOfDetail];
}

- (RZXGPUObjectTeardownBlock)teardownHandler
{
    RZXGPUObjectTeardownBlock superTeardown = [super teardownHandler];

    GLuint fbo = _fbos[1];
    GLuint drb = _drbs[1];

    GLuint *auxTex = (GLuint *)malloc(sizeof(_auxTex));
    memcpy(auxTex, _auxTex, sizeof(_auxTex));

    return ^(RZXGLContext *context) {
        if ( superTeardown != nil ) {
            superTeardown(context);
        }

        glDeleteFramebuffers(1, &fbo);
        glDeleteRenderbuffers(1, &drb);
        glDeleteTextures(2 * RZX_EFFECT_AUX_TEXTURES, auxTex);

        free(auxTex);
    };
}

- (void)setupGL
{
    [super setupGL];

    [self createTexture];
}

- (void)teardownGL
{
    [super teardownGL];

    memset(_fbos, 0, 2 * sizeof(GLuint));
    memset(_drbs, 0, 2 * sizeof(GLuint));
    memset(_auxTex, 0, sizeof(_auxTex));
}

#pragma mark - RZUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    [super rzx_update:dt];

    if ( self.isDynamic || !self.textureLoaded ) {
        [self.viewTexture updateWithView:self.sourceView synchronous:self.synchronousUpdate];
        self.textureLoaded = YES;
    }
}

- (void)display
{
    static const GLenum s_GLDiscards[] = {GL_DEPTH_ATTACHMENT, GL_COLOR_ATTACHMENT0};

    [self.context runBlock:^(RZXGLContext *context){
        context.depthTestEnabled = YES;
        context.cullFace = GL_BACK;

        context.activeTexture = GL_TEXTURE0;
        context.clearColor = self.backgroundColor.CGColor;

        [self.viewTexture bindGL];
        [self congfigureEffect];

        int fbo = 0;

        GLuint downsample = self.effect.downsampleLevel;
        GLint denom = pow(2.0, downsample);

        while ( [self.effect prepareToDraw] ) {
            context.viewport = CGRectMake(0.0f, 0.0f, self->_backingWidth/denom, self->_backingHeight/denom);
            glBindFramebuffer(GL_FRAMEBUFFER, self->_fbos[fbo]);

            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self->_auxTex[fbo][downsample], 0);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            [self.model rzx_render];

            [context invalidateFramebufferAttachments:s_GLDiscards count:1];
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
            [context invalidateFramebufferAttachments:s_GLDiscards+1 count:1];

            glBindTexture(GL_TEXTURE_2D, self->_auxTex[fbo][downsample]);
            fbo = 1 - fbo;

            downsample = self.effect.downsampleLevel;
            denom = pow(2.0, downsample);
        };

        // TODO: what if the last effect has lower downsample?

        context.viewport = CGRectMake(0.0f, 0.0f, self->_backingWidth, self->_backingHeight);

        glBindFramebuffer(GL_FRAMEBUFFER, self->_fbos[fbo]);

        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _crb);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        [self.model rzx_render];

        [context invalidateFramebufferAttachments:s_GLDiscards count:1];

        glBindRenderbuffer(GL_RENDERBUFFER, self->_crb);
        [context presentRenderbuffer:GL_RENDERBUFFER];

        [context invalidateFramebufferAttachments:s_GLDiscards+1 count:1];

        glBindTexture(GL_TEXTURE_2D, 0);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
    } wait:NO];
}

#pragma mark - protected methods

- (void)createBuffers
{
    [super createBuffers];

    _fbos[0] = _fbo;
    _drbs[0] = _drb;

    glGenFramebuffers(1, &_fbos[1]);
    glGenRenderbuffers(1, &_drbs[1]);

    glBindFramebuffer(GL_FRAMEBUFFER, _fbos[1]);
    glBindRenderbuffer(GL_RENDERBUFFER, _drbs[1]);

    glGenTextures(2 * RZX_EFFECT_AUX_TEXTURES, _auxTex[0]);

    for ( int tex = 0; tex < 2; tex++ ) {
        for ( int i = 0; i < RZX_EFFECT_AUX_TEXTURES; i++ ) {
            GLsizei denom = pow(2.0, i);

            glBindTexture(GL_TEXTURE_2D, _auxTex[tex][i]);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _backingWidth / denom, _backingHeight / denom, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        }
    }

    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _backingWidth, _backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _drbs[1]);

    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}

- (void)destroyBuffers
{
    [super destroyBuffers];

    if ( _fbos[1] != 0 ) {
        glDeleteFramebuffers(1, &_fbos[1]);
        glDeleteRenderbuffers(1, &_drbs[1]);
        glDeleteTextures(2 * RZX_EFFECT_AUX_TEXTURES, _auxTex[0]);
    }

    memset(_fbos, 0, 2 * sizeof(GLuint));
    memset(_drbs, 0, 2 * sizeof(GLuint));
    memset(_auxTex, 0, sizeof(_auxTex));
}

#pragma mark - private methods

- (RZXGLContext *)context
{
    return _context;
}

- (void)setSourceView:(UIView *)sourceView
{
    _sourceView = sourceView;

    self.effectCamera = [RZXCamera cameraWithFieldOfView:GLKMathDegreesToRadians(30.0f) aspectRatio:1.0f nearClipping:0.001f farClipping:100.0f];

    self.effectTransform = [RZXTransform3D transform];

    [self createTexture];
    [self updateCamera];
}

- (void)updateCamera
{
    CGFloat aspectRatio = (CGRectGetWidth(self.bounds) / CGRectGetWidth(self.bounds));
    self.effectCamera.aspectRatio = aspectRatio;

    GLKVector3 camTrans = GLKVector3Make(0.0f, 0.0f, -1.0f / tanf(self.effectCamera.fieldOfView / 2.0f));
    self.effectTransform.translation = camTrans;
}

- (void)createTexture
{
    if ( self.sourceView != nil ) {
        [self.context runBlock:^(RZXGLContext *context) {
            self.viewTexture = [RZXViewTexture textureWithSize:self.sourceView.bounds.size];
            [self.viewTexture setupGL];

            self.textureLoaded = NO;
        }];
    }
}

- (void)congfigureEffect
{
    GLKMatrix4 model, view, projection;
    
    if ( self.effectTransform != nil ) {
        model = self.effectTransform.modelMatrix;
    }
    else {
        model = GLKMatrix4Identity;
    }
    
    if ( self.effectCamera != nil ) {
        view = self.effectCamera.viewMatrix;
        projection = self.effectCamera.projectionMatrix;
    }
    else {
        view = GLKMatrix4Identity;
        projection = GLKMatrix4Identity;
    }
    
    self.effect.resolution = GLKVector2Make(_backingWidth, _backingHeight);
    self.effect.modelViewMatrix = GLKMatrix4Multiply(view, model);
    self.effect.projectionMatrix = projection;
}

@end
