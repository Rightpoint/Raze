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
@class RZXGLView;

@protocol RZXGLViewDelegate <NSObject>

/**
 *  Called every frame on the main queue, during the update cycle.
 *
 *  @param view The view that needs updating.
 *  @param dt   The time delta since the last update callback.
 */
@optional
- (void)glView:(RZXGLView *)view update:(NSTimeInterval)dt;

/**
 *  Called every frame on the background rendering queue, during the render phase.
 *  When this method is called, the appropriate RZXGLContext will be current.
 *
 *  @param view The view to render.
 */
@optional
- (void)glViewRender:(RZXGLView *)view;

@end

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

/** The size of the framebuffer backing the view. Based on contentScaleFactor and bounds. */
@property (nonatomic, readonly) GLKVector2 resolution;

/** The render duration of the previous frame, in seconds. */
@property (assign, nonatomic, readonly) NSTimeInterval previousFrameDuration;

/** Frames per second specified between 1 and 60. */
@property (assign, nonatomic) IBInspectable NSInteger framesPerSecond;

/*  Multisample level specified between 0 and 4. */
@property (assign, nonatomic) IBInspectable GLsizei multisampleLevel;

/** Whether the render loop is currently running. */
@property (assign, nonatomic, getter=isPaused) BOOL paused;

/**
 *  Whether the view supports multithreading.
 *  If YES, frames will be rendered serially, but rendering will not block the main thread.
 *  Default is YES.
 */
@property (assign, nonatomic, getter=isMultithreaded) BOOL multithreaded;

/** The model to be rendered each frame. */
@property (strong, nonatomic) id<RZXRenderable> model;

@property (nonatomic, readonly) RZXGPUObjectTeardownBlock teardownHandler;

@property (weak, nonatomic) id<RZXGLViewDelegate> delegate;

- (void)setupGL;
- (void)teardownGL;

- (void)display;

@end

#pragma clang diagnostic pop
