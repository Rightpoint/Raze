//
//  RZXRenderLoop.m
//
//  Created by Rob Visentin on 1/10/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RZXRenderLoop.h"

static const NSInteger kRZRenderLoopDefaultFPS = 30;

@interface RZXRenderLoop ()

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) BOOL pausedWhileInactive;

@property (weak, nonatomic) id<RZXUpdateable> updateTarget;
@property (weak, nonatomic) id<RZXRenderable> renderTarget;

@property (assign, nonatomic, readwrite) CFTimeInterval lastRender;
@property (assign, nonatomic, readwrite, getter=isRunning) BOOL running;

@end

@implementation RZXRenderLoop

+ (instancetype)renderLoop
{
    return [[[self class] alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        _automaticallyResumeWhenForegrounded = YES;
        
        [self setupDisplayLink];
    }
    return self;
}

- (void)dealloc
{
    [self teardownDisplayLink];
}

- (void)setPreferredFPS:(NSInteger)preferredFPS
{
    _preferredFPS = MAX(1, MIN(preferredFPS, 60));
    self.displayLink.frameInterval = 60 / _preferredFPS;
}

- (void)run
{
    self.lastRender = CACurrentMediaTime();
    
    self.running = YES;
}

- (void)stop
{
    self.running = NO;
}
                        
#pragma mark - private methods

- (void)setupDisplayLink
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
    self.displayLink.paused = YES;

    self.preferredFPS = kRZRenderLoopDefaultFPS;
    
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)teardownDisplayLink
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)setRunning:(BOOL)running
{
    _running = running;
    self.displayLink.paused = !running;
}

- (void)didEnterBackground:(NSNotification *)notification
{
    if ( self.isRunning ) {
        [self stop];
        self.pausedWhileInactive = YES;
    }
}

- (void)willEnterForeground:(NSNotification *)notification
{
    if ( self.pausedWhileInactive && self.automaticallyResumeWhenForegrounded ) {
        [self run];
    }
}

- (void)displayLinkTick:(CADisplayLink *)displayLink
{
    CFTimeInterval dt = displayLink.timestamp - self.lastRender;
    
    [self.updateTarget update:dt];

    [self.renderTarget render];
    
    self.lastRender = displayLink.timestamp;
}

@end
