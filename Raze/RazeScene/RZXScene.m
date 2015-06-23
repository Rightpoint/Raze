//
//  RZXScene.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeEffects/RZXPassthroughEffect.h>

#import "RZXScene.h"

@implementation RZXScene

+ (instancetype)sceneWithEffect:(RZXEffect *)effect
{
    return [[RZXScene alloc] initWithEffect:effect];
}

- (instancetype)init
{
    return [self initWithEffect:[RZXPassthroughEffect effect3D]];
}

- (instancetype)initWithEffect:(RZXEffect *)effect
{
    self = [super init];
    if (self) {
        self.effect = effect;
    }
    return self;
}

- (void)bindGL
{
    // no-op. The scene object itself isn't renderable
}

@end
