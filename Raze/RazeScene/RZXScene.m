//
//  RZXScene.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeEffects/RZXPassthroughEffect.h>

#import <RazeScene/RZXScene.h>
#import <RazeScene/RZXNode_Private.h>

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
    if ( (self = [super init]) ) {
        self.effect = effect;

        _rootNode = [[[self class] rootNodeClass] node];
        [super addChild:_rootNode];

        _physicsWorld = [[RZXPhysicsWorld alloc] init];
    }

    return self;
}

- (RZXScene *)scene
{
    return self;
}

- (void)addChild:(RZXNode *)child
{
    RZXLog("WARNING: Nodes should be added to a scene's rootNode, not the scene itself. %@ will be added to the root node instead.", child);
    [_rootNode addChild:child];
}

- (void)rzx_update:(NSTimeInterval)dt
{
    [super rzx_update:dt];

    NSSet *collisions = [self.physicsWorld computeCollisions];

    for ( RZXCollision *collision in collisions ) {
        // TODO: began/end contact callbacks

        // Revert updates to pre-collision state
        [collision.first.body.node revertToSnapshot];
        [collision.second.body.node revertToSnapshot];
    }

    // Save latest valid state
    [self.physicsWorld enumerateCollidersWithBlock:^(RZXCollider *collider) {
        [collider.body.node snapshotCurrentTransform];
    }];
}

@end

@implementation RZXSceneRootNode

- (void)removeFromParent
{
    // no-op. Scene root nodes shouldn't be removed.
}

@end

@implementation RZXNode (RZXScene)

- (void)didMoveToScene:(RZXScene *)scene
{
    // subclass override
}

@end
