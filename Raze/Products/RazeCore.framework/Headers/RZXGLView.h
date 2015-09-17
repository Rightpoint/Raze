//
//  RZXGLView.h
//
//  Created by Rob Visentin on 3/15/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RazeCore/RZXUpdateable.h>
#import <RazeCore/RZXRenderable.h>
#import <RazeCore/RZXGPUObject.h>

@class RZXGLContext;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"

/**
 *  UIView with a CAEAGLayer, used for all OpenGL rendering.
 *  Subclasses should be used to perform more nuanced rendering.
 */
@interface RZXGLView : UIView <RZXUpdateable, RZXRenderable> {
    @protected
    RZXGLContext *_context;

    // buffer indices for frame buffer, color render buffer, and depth render buffer
    GLuint _fbo;
    GLuint _crb;
    GLuint _drb;

    // buffer indices for multisampling
    GLuint _msFbo;
    GLuint _msCrb;
    GLuint _msDrb;

    GLint _backingWidth;
    GLint _backingHeight;
}

/** Frames per second specified between 1 and 60. */
@property (assign, nonatomic) IBInspectable NSInteger framesPerSecond;

/*  Multisample level specified between 0 and 4. */
@property (assign, nonatomic) IBInspectable GLsizei multisampleLevel;

// Pausing will stop the render loop
@property (assign, nonatomic, getter=isPaused) BOOL paused;

// Model for the view
@property (strong, nonatomic) id<RZXRenderable> model;

@property (nonatomic, readonly) RZXGPUObjectTeardownBlock teardownHandler;

- (void)setupGL;
- (void)teardownGL;

- (void)display;

@end

#pragma clang diagnostic pop
