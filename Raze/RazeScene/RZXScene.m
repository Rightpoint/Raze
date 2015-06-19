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

- (instancetype)init
{
    if ( (self = [super init]) ) {
        self.effect = [RZXPassthroughEffect effect3D];
    }
    return self;
}

- (void)bindGL
{
    // no-op. The scene object itself isn't renderable
}

@end
