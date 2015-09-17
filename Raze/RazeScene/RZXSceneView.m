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
    self = [self initWithFrame:frame];
    if (self) {
        self.scene = scene;
    }
    return self;
}

- (void)setScene:(RZXScene *)scene
{
    _scene = scene;

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

#pragma mark - drawing

- (void)rzx_update:(NSTimeInterval)dt
{
    [super rzx_update:dt];
    [self.scene rzx_update:dt];
}

- (void)display
{
    self.scene.resolution = GLKVector2Make(_backingWidth, _backingHeight);
    [super display];
}

@end
