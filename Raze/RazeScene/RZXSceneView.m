//
//  RZXSceneView.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXSceneView.h"
#import <RazeScene/RazeScene.h>
#import <OpenGLES/ES2/glext.h>

@interface RZXSceneView(RZProtected)

- (void)createBuffers;
- (void)destroyBuffers;

@end

@interface RZXSceneView() <RZXUpdateable, RZXRenderable>
{
    GLint _backingWidth;
    GLint _backingHeight;
    
    GLuint _viewColorRenderbuffer;
    GLuint _viewFramebuffer;
    GLuint _viewDepthRenderbuffer;
    
    GLuint _sampleFramebuffer;
    GLuint _sampleColorRenderbuffer;
    GLuint _sampleDepthRenderbuffer;
}

@property (strong, nonatomic) IBOutlet UIView *sourceView;

@end

@implementation RZXSceneView

- (instancetype)initWithSourceView:(UIView *)view scene:(RZXScene *)scene
{
    self = [super initWithFrame:view.bounds];
    if (self) {
        _sourceView = view;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updateAfterViewRectChange];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self updateAfterViewRectChange];
}

#pragma mark - private methods

- (RZXGLContext *)context
{
    return _context;
}

- (void)prepareLayerAndBuffers
{
    // clear old buffer objects
    [self deleteBuffers];
    
    // can't create buffers with width or height of 0
    if ( CGRectIsEmpty(self.bounds) ) {
        return;
    }
    
    [self.context runBlock:^(RZXGLContext *context) {
        // drawing and multisample formats are hard coded for now
        GLuint numberOfSamples = 4;
        GLuint depthFormat = GL_DEPTH_COMPONENT16;
        
        CAEAGLLayer *glLayer = (CAEAGLLayer *)self.layer;
        glLayer.contentsScale = [UIScreen mainScreen].scale;
        
        glLayer.drawableProperties = @{ kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8, kEAGLDrawablePropertyRetainedBacking : @(NO) };
        
        glGenFramebuffers(1, &_viewFramebuffer);
        glGenRenderbuffers(1, &_viewColorRenderbuffer);
        glGenRenderbuffers(1, &_viewDepthRenderbuffer);
        
        glBindFramebuffer(GL_FRAMEBUFFER, _viewFramebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _viewColorRenderbuffer);
        [self->_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:glLayer];
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _viewColorRenderbuffer);
        
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
        
        glBindRenderbuffer(GL_RENDERBUFFER, _viewDepthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, depthFormat, _backingWidth, _backingHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _viewDepthRenderbuffer);
        
        if ( glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Failed to make complete framebuffer object %i", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        }
        
        // multisampling
        glGenFramebuffers(1, &_sampleFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _sampleFramebuffer);
        
        glGenRenderbuffers(1, &_sampleColorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _sampleColorRenderbuffer);
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, numberOfSamples, GL_RGBA8_OES, _backingWidth, _backingHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _sampleColorRenderbuffer);
        
        glGenRenderbuffers(1, &_sampleDepthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _sampleDepthRenderbuffer);
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, numberOfSamples, depthFormat, _backingWidth, _backingHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _sampleDepthRenderbuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"Failed to make complete multisample framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }];
}

- (void)deleteBuffers
{
    if ( _viewFramebuffer != 0 ) {
        glDeleteFramebuffers(1, &_viewFramebuffer);
        glDeleteRenderbuffers(1,&_viewColorRenderbuffer);
        glDeleteRenderbuffers(1, &_viewDepthRenderbuffer);
        
        if ( _sampleFramebuffer != 0 ) {
            glDeleteFramebuffers(1, &_sampleFramebuffer);
            glDeleteRenderbuffers(1, &_sampleColorRenderbuffer);
            glDeleteRenderbuffers(1, &_sampleDepthRenderbuffer);
        }
    }
}

- (void)recreateLayerAndBuffersIfNeeded
{
    CGSize currentSize = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize frameSize = CGSizeMake(_backingWidth / scale, _backingHeight / scale );
    
    if ( !CGSizeEqualToSize(currentSize, frameSize) ) {
        [self prepareLayerAndBuffers];
    }
}

- (void)updateAfterViewRectChange
{
    [self recreateLayerAndBuffersIfNeeded];
}

#pragma mark - drawing

- (void)update:(NSTimeInterval)dt
{
    [super update:dt];
    [self.scene update:dt];
}

- (void)display
{
    [self.context runBlock:^(RZXGLContext *context) {
        glBindFramebuffer(GL_FRAMEBUFFER, _sampleFramebuffer);
        glViewport(0, 0, _backingWidth, _backingHeight);
    
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _viewFramebuffer);
        glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _sampleFramebuffer);
        glResolveMultisampleFramebufferAPPLE();
        
        const GLenum discards[]  = {GL_COLOR_ATTACHMENT0,GL_DEPTH_ATTACHMENT};
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE,2,discards);
    
        glBindRenderbuffer(GL_RENDERBUFFER, _viewColorRenderbuffer);
        [self->_context presentRenderbuffer:GL_RENDERBUFFER];

        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
    }];
}

@end
