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
    self.model = scene;
}

#pragma mark - drawing

- (void)update:(NSTimeInterval)dt
{
    [super update:dt];
    [self.scene update:dt];
}

@end
