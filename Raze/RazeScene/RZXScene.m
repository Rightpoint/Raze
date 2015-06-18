//
//  RZXScene.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXEffect.h>

#import "RZXScene.h"

@implementation RZXScene

- (instancetype)init
{
    if ( (self = [super init]) ) {
        self.effect = [RZXEffect effectWithVertexShader:kRZXEffectDefaultVSH3D fragmentShader:kRZXEffectDefaultFSH];
    }
    return self;
}

@end
