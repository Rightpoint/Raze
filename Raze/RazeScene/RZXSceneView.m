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

@interface RZXGLView(RZProtected)

- (void)createBuffers;
- (void)destroyBuffers;

@end

@implementation RZXSceneView {
    GLuint _sampleFramebuffer;
    GLuint _sampleColorRenderbuffer;
    GLuint _sampleDepthRenderbuffer;
}

- (instancetype)initWithFrame:(CGRect)frame scene:(RZXScene *)scene
{
    self = [self initWithFrame:frame];
    if (self) {
        self.scene = scene;
    }
    return self;
}


- (void)setScene:(RZXScene *)scene
{
    _scene = scene;
    self.model = scene;
}

#pragma mark - private methods

- (RZXGLContext *)context
{
    return _context;
}

- (void)createBuffers
{
    [super createBuffers];
    
    // TODO multisampling in the superclass

        /*
        // drawing and multisample formats are hard coded for now
        GLuint numberOfSamples = 1;
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
            NSLog(@"Failed to make complete multisample framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));*/
}

#pragma mark - drawing

- (void)update:(NSTimeInterval)dt
{
    [super update:dt];
    [self.scene update:dt];
}

// TODO: handle multisampling here in the superclass

/*- (void)display
{
    [self.context runBlock:^(RZXGLContext *context) {
        glBindFramebuffer(GL_FRAMEBUFFER, _viewFramebuffer);
        glViewport(0, 0, _backingWidth, _backingHeight);
        
        [self bindGL];
        
        [self.scene render];
        
        glBindRenderbuffer(GL_RENDERBUFFER, _viewColorRenderbuffer);
        [context presentRenderbuffer:GL_RENDERBUFFER];
        
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);

        /*
        glBindFramebuffer(GL_FRAMEBUFFER, _sampleFramebuffer);
        glViewport(0, 0, _backingWidth, _backingHeight);
        
        [self bindGL];
        
        [self.scene render];
    
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
*/
@end
