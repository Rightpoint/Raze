//
//  RZXGLView.h
//
//  Created by Rob Visentin on 3/15/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RazeCore/RZXUpdateable.h>
#import <RazeCore/RZXRenderable.h>

@class RZXGLContext;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"

@interface RZXGLView : UIView <RZXUpdateable, RZXRenderable> {
    @protected
    RZXGLContext *_context;
    
    GLuint _fbo;
    GLuint _crb;
    GLuint _drb;
    
    GLuint _msFbo;
    GLuint _msCrb;
    GLuint _msDrb;

    GLint _backingWidth;
    GLint _backingHeight;
}

@property (assign, nonatomic) IBInspectable NSInteger framesPerSecond;
@property (assign, nonatomic) IBInspectable GLsizei multisampleLevel;
@property (assign, nonatomic, getter=isPaused) BOOL paused;

@property (strong, nonatomic) id<RZXRenderable> model;

- (void)setupGL;
- (void)teardownGL;

- (void)display;

@end

#pragma clang diagnostic pop
