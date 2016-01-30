//
//  RZXScene.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeEffects/RZXPassthroughEffect.h>

#import "RZXScene.h"

@interface RZXSceneRootNode : RZXNode
@end

@implementation RZXScene

+ (Class)rootNodeClass
{
    return [RZXSceneRootNode class];
}

+ (instancetype)scene
{
    return [self node];
}

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

        _rootNode = [[[self class] rootNodeClass] node];
        [super addChild:_rootNode];
    }
    return self;
}

- (void)addChild:(RZXNode *)child
{
    RZXLog("WARNING: Nodes should be added to a scene's rootNode, not the scene itself. %@ will be added to the root node instead.", child);
    [_rootNode addChild:child];
}

@end

@implementation RZXSceneRootNode

- (void)removeFromParent
{
    // no-op. Scene root nodes shouldn't be removed.
}

@end
