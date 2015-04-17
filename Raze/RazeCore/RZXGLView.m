//
//  RZXGLView.m
//
//  Created by Rob Visentin on 3/15/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>
#import <RazeCore/RZXGLView.h>
#import <RazeCore/RZXGLContext.h>
#import <RazeCore/RZXRenderLoop.h>

@interface RZXGLView ()

@property (strong, nonatomic) RZXGLContext *context;
@property (strong, nonatomic) RZXRenderLoop *renderLoop;

@end

@implementation RZXGLView

@synthesize context = _context;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

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
    [self.context runBlock:^(RZXGLContext *context) {
        [self teardownGL];
    }];
}

#pragma mark - public methods

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    [self.context runBlock:^(RZXGLContext *context){
        [self updateBuffersWithSize:frame.size];
    }];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];

    [self.context runBlock:^(RZXGLContext *context){
        [self updateBuffersWithSize:bounds.size];
    }];
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

- (void)setModel:(id<RZXRenderable>)model
{
    [self.context runBlock:^(RZXGLContext *context) {
        [self->_model teardownGL];
        self->_model = model;
        [self->_model setupGL];
    }];
}

- (void)setNeedsDisplay
{
    // empty implementation
}

- (void)display
{
    static const GLenum s_GLDiscards[] = {GL_DEPTH_ATTACHMENT, GL_COLOR_ATTACHMENT0};

    [self.context runBlock:^(RZXGLContext *context) {
        glBindFramebuffer(GL_FRAMEBUFFER, self->_fbo);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        [self bindGL];

        [self.model render];

        glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, s_GLDiscards);

        glBindRenderbuffer(GL_RENDERBUFFER, self->_crb);
        [context presentRenderbuffer:GL_RENDERBUFFER];

        glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, &s_GLDiscards[1]);

        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
    }];
}

#pragma mark - RZUpdateable

- (void)update:(NSTimeInterval)dt
{
    // subclass override
}

#pragma mark - RZRenderable

- (void)setupGL
{
    [self.context runBlock:^(RZXGLContext *context){
        [self teardownGL];

        self.renderLoop = [RZXRenderLoop renderLoop];
        [self.renderLoop setUpdateTarget:self];
        [self.renderLoop setRenderTarget:self];

        if ( self.superview != nil && !self.isPaused ) {
            [self.renderLoop run];
        }

        [self updateBuffersWithSize:self.bounds.size];
    }];
}

- (void)bindGL
{
    [self.model bindGL];
}

- (void)teardownGL
{
    [self.context runBlock:^(RZXGLContext *context){
        [self.renderLoop stop];
        self.renderLoop = nil;

        [self destroyBuffers];
        [self.model teardownGL];
    }];
}

- (void)render
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

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);

    glGenRenderbuffers(1, &_drb);
    glBindRenderbuffer(GL_RENDERBUFFER, _drb);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, _backingWidth, _backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _drb);

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

    _fbo = 0;
    _crb = 0;
    _drb = 0;

    _backingWidth = 0;
    _backingHeight = 0;
}

@end
