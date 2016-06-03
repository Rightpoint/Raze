//
//  RZXRenderLoop.h
//
//  Created by Rob Visentin on 1/10/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXUpdateable.h>
#import <RazeCore/RZXRenderable.h>

@interface RZXRenderLoop : NSObject

@property (assign, nonatomic, readonly) CFTimeInterval lastRender;
@property (assign, nonatomic, readonly, getter=isRunning) BOOL running;

@property (assign, nonatomic, readonly, getter=isValid) BOOL valid;

@property (assign, nonatomic) BOOL automaticallyResumeWhenForegrounded; // default YES

@property (assign, nonatomic) NSInteger preferredFPS; // default 30

- (void)setUpdateTarget:(id<RZXUpdateable>)updateTarget;
- (void)setRenderTarget:(id<RZXRenderable>)renderTarget;

- (void)run;
- (void)stop;

- (void)invalidate;

@end
