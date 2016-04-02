//
//  RZXScene.h
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeScene/RZXNode.h>

@class RZXPhysicsWorld;

#pragma mark - RZXScene

@interface RZXScene : RZXNode

/**
 *  The root node of the scene. 
 *  Children of the scene should be added to this node instead of the scene itself to ensure proper transform heirarchy.
 *  Animations and transforms that should affect the entire scene should be set on this node.
 */
@property (nonatomic, readonly) RZXNode *rootNode;

/**
 *  The physics world associated with the scene.
 */
@property (nonatomic, readonly) RZXPhysicsWorld *physicsWorld;

+ (instancetype)scene;
+ (instancetype)sceneWithEffect:(RZXEffect *)effect;

/**
 *  The class to use when initializing the scene's root node.
 */
+ (Class)rootNodeClass;

/**
 *  Called once the physics pass has run after the update phase, just before the render phase.
 *  Any changes to to the physics system in this method will not be applied until the next frame.
 */
- (void)didSimulatePhysics;

@end

#pragma mark - RZXNode + RZXScene

@interface RZXNode (RZXScene)

/**
 *  The scene at the root of the receiver's node heirarchy.
 */
@property (weak, nonatomic, readonly) RZXScene *scene;

/**
 *  Called when the node is added to or removed from a scene.
 *  The default implementation of this method does nothing, but subclasses may override.
 *
 *  @param scene The scene the receiver moved to, or nil if the receiver was removed from a scene.
 */
- (void)didMoveToScene:(RZXScene *)scene;

@end
