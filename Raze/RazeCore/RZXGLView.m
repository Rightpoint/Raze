//
//  RZXGLView.m
//
//  Created by Rob Visentin on 3/15/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <OpenGLES/ES3/gl.h>
#import <RazeCore/RZXGLView.h>
#import <RazeCore/RZXGLContext.h>
#import <RazeCore/RZXRenderLoop.h>

@interface RZXGLView ()

@property (strong, nonatomic) RZXGLContext *context;
@property (strong, nonatomic) RZXRenderLoop *renderLoop;

@end

@implementation RZXGLView

@synthesize context = _context;

#pragma mark - lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self configureContext];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self configureContext];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ( newSuperview == nil ) {
        [self.renderLoop stop];
    }
}

- (void)didMoveToSuperview
{
    if ( self.superview != nil && !self.isPaused ) {
        [self.renderLoop run];
    }
}

- (void)dealloc
{
    [self teardownGL];
}

#pragma mark - public methods

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    [self updateBuffersWithSize:frame.size];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];

    [self updateBuffersWithSize:bounds.size];
}

- (void)setPaused:(BOOL)paused
{
    if ( paused != _paused ) {
        if ( paused ) {
            [self.renderLoop stop];
        }
        else {
            [self.renderLoop run];
        }

        _paused = paused;
    }
}

- (void)setFramesPerSecond:(NSInteger)framesPerSecond
{
    _framesPerSecond = framesPerSecond;
    self.renderLoop.preferredFPS = framesPerSecond;
}

- (void)setNeedsDisplay
{
    // empty implementation
}

- (RZXGPUObjectTeardownBlock)teardownHandler
{
    GLuint fbo = _fbo;
    GLuint crb = _crb;
    GLuint drb = _drb;

    GLuint msFbo = _msFbo;
    GLuint msCrb = _msCrb;
    GLuint msDrb = _msDrb;

    return ^(RZXGLContext *context) {
        glDeleteFramebuffers(1, &fbo);
        glDeleteRenderbuffers(1, &crb);
        glDeleteRenderbuffers(1, &drb);

        glDeleteFramebuffers(1, &msFbo);
        glDeleteFramebuffers(1, &msCrb);
        glDeleteFramebuffers(1, &msDrb);
    };
}

- (void)setupGL
{
    [self updateBuffersWithSize:self.bounds.size];

    self.renderLoop = [RZXRenderLoop renderLoop];
    [self.renderLoop setUpdateTarget:self];
    [self.renderLoop setRenderTarget:self];

    if ( self.superview != nil && !self.isPaused ) {
        [self.renderLoop run];
    }
}

- (void)teardownGL
{
    [self.renderLoop invalidate];
    self.renderLoop = nil;
    
    if ( self.teardownHandler != nil ) {
        [self.context runBlock:self.teardownHandler wait:NO];
    }

    _fbo = 0;
    _crb = 0;
    _drb = 0;

    _msFbo = 0;
    _msCrb = 0;
    _msDrb = 0;

    _backingWidth = 0;
    _backingHeight = 0;
}

- (void)display
{
    static const GLenum s_GLDiscards[] = {GL_DEPTH_ATTACHMENT, GL_COLOR_ATTACHMENT0};

    [self.context runBlock:^(RZXGLContext *context) {
        context.clearColor = self.backgroundColor.CGColor;
        context.viewport = CGRectMake(0.0f, 0.0f, self->_backingWidth, self->_backingHeight);
        context.depthTestEnabled = YES;
        
        GLuint targetFbo = self.multisampleLevel > 0 ? _msFbo : _fbo;
        glBindFramebuffer(GL_FRAMEBUFFER, targetFbo);
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        [self.model rzx_render];
        
        if (self.multisampleLevel > 0) {
            glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _fbo);
            glBindFramebuffer(GL_READ_FRAMEBUFFER, _msFbo);
            
            //TODO: distinguish between openGL 2.0 and 3.0 calls here. For 2.0 glBlitFrameBuffer is replaced by appleResolveMultiSample
            glBlitFramebuffer(0, 0, _backingWidth, _backingHeight, 0, 0, _backingWidth, _backingHeight, GL_COLOR_BUFFER_BIT, GL_LINEAR);
            glInvalidateFramebuffer(GL_DRAW_FRAMEBUFFER, 1, &s_GLDiscards[1]);
            glInvalidateFramebuffer(GL_READ_FRAMEBUFFER, 1, s_GLDiscards);
        }
        
        glInvalidateFramebuffer(GL_FRAMEBUFFER, 1, s_GLDiscards);

        glBindRenderbuffer(GL_RENDERBUFFER, self->_crb);
        [context presentRenderbuffer:GL_RENDERBUFFER];

        glInvalidateFramebuffer(GL_FRAMEBUFFER, 1, &s_GLDiscards[1]);

        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
    } wait:NO];
}

#pragma mark - RZUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    // subclass override
}

#pragma mark - RZXRenderable

- (void)rzx_render
{
    [self display];
}

#pragma mark - private methods

- (void)configureContext
{
    CAEAGLLayer *glLayer = (CAEAGLLayer *)self.layer;
    glLayer.contentsScale = [UIScreen mainScreen].scale;

    glLayer.drawableProperties = @{ kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyRetainedBacking : @(NO) };

    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.userInteractionEnabled = NO;

    self.context = [RZXGLContext defaultContext];

    [self setupGL];
}

- (void)updateBuffersWithSize:(CGSize)size
{
    [self.context runBlock:^(RZXGLContext *context) {
        [self destroyBuffers];

        if ( size.width > 0.0f && size.height > 0.0f ) {
            [self createBuffers];
        }
    }];
}

- (void)createBuffers
{
    RZXGLContext *context = [RZXGLContext currentContext];

    glGenFramebuffers(1, &_fbo);
    glGenRenderbuffers(1, &_crb);

    glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    glBindRenderbuffer(GL_RENDERBUFFER, _crb);

    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _crb);

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);

    glGenRenderbuffers(1, &_drb);
    glBindRenderbuffer(GL_RENDERBUFFER, _drb);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _backingWidth, _backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _drb);

    if ( glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE ) {
        RZXLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }

    if ( self.multisampleLevel > 0 )
    {
        glGenFramebuffers(1, &_msFbo);
        glGenRenderbuffers(1, &_msCrb);
        
        glBindFramebuffer(GL_FRAMEBUFFER, _msFbo);
        glBindRenderbuffer(GL_RENDERBUFFER, _msCrb);
        
        glRenderbufferStorageMultisample(GL_RENDERBUFFER, self.multisampleLevel, GL_RGBA8, _backingWidth, _backingHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _msCrb);
        
        glGenRenderbuffers(1, &_msDrb);
        glBindRenderbuffer(GL_RENDERBUFFER, _msDrb);
        glRenderbufferStorageMultisample(GL_RENDERBUFFER, self.multisampleLevel, GL_DEPTH_COMPONENT16, _backingWidth, _backingHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _msDrb);
     
        if ( glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE ) {
            RZXLog(@"Failed to make complete multisample framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        }
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
}

- (void)destroyBuffers
{
    if ( _fbo != 0 ) {
        glDeleteFramebuffers(1, &_fbo);
        glDeleteRenderbuffers(1, &_crb);
        glDeleteRenderbuffers(1, &_drb);
    }

    if ( _msFbo != 0 ) {
        glDeleteFramebuffers(1, &_msFbo);
        glDeleteFramebuffers(1, &_msCrb);
        glDeleteFramebuffers(1, &_msDrb);
    }

    _fbo = 0;
    _crb = 0;
    _drb = 0;

    _msFbo = 0;
    _msCrb = 0;
    _msDrb = 0;

    _backingWidth = 0;
    _backingHeight = 0;
}

@end
