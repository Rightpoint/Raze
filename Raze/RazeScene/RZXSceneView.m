//
//  RZXSceneView.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeScene/RZXSceneView.h>
#import <RazeScene/RazeScene.h>

@implementation RZXSceneView

- (instancetype)initWithFrame:(CGRect)frame scene:(RZXScene *)scene
{
    if ( (self = [self initWithFrame:frame]) ) {
        self.scene = scene;
    }
    return self;
}

- (RZXScene *)scene
{
    return [self.model isKindOfClass:[RZXScene class]] ? self.model : nil;
}

- (void)setScene:(RZXScene *)scene
{
    [_context runBlock:^(RZXGLContext *context) {
        [scene setupGL];
    }];

    self.model = scene;
}

- (void)setupGL
{
    [super setupGL];
    [self.scene setupGL];
}

- (void)teardownGL
{
    [super teardownGL];
    [self.scene teardownGL];
}

#pragma mark - drawing

- (void)rzx_update:(NSTimeInterval)dt
{
    [super rzx_update:dt];
    [self.scene rzx_update:dt];
}

- (void)display
{
    self.scene.resolution = self.resolution;
    [super display];
}

@end
