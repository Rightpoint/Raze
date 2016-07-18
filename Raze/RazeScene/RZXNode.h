//
//  RZXNode.h
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXGPUObject.h>
#import <RazeCore/RZXRenderable.h>
#import <RazeCore/RZXUpdateable.h>

#import <RazePhysics/RZXPhysicsBody.h>

@class RZXTransform3D;
@class RZXEffect;
@class RZXCamera;
@class RZXAnimator;

/**
 *  The base class of any object in a scene.
 */
@interface RZXNode : RZXGPUObject <RZXRenderable, RZXUpdateable>

/**
 *  An identifier for use by your application.
 */
@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) RZXTransform3D *transform;
@property (strong, nonatomic) RZXEffect *effect;
@property (strong, nonatomic) RZXCamera *camera;

@property (assign, nonatomic) GLKVector2 resolution;

@property (copy, nonatomic, readonly) NSArray *children;
@property (weak, nonatomic, readonly) RZXNode *parent;

@property (nonatomic, readonly) RZXAnimator *animator;

+ (instancetype)node;

- (void)addChild:(RZXNode *)child;
- (void)insertChild:(RZXNode *)child atIndex:(NSUInteger)index;

- (void)removeFromParent;

/**
 *  Called when the node is added to or removed from a parent node.
 *  The default implementation of this method does nothing, but subclasses may override.
 *
 *  @param parent The new parent of the receiver, or nil if the receiver was removed from its parent.
 */
- (void)didMoveToParent:(RZXNode *)parent;

/**
 *  Returs YES if the receiver is an immediate or distant child of `node` or if `view` is the receiver itself.
 */
- (BOOL)isDescendantOfNode:(RZXNode *)node;

- (GLKMatrix4)modelMatrix;
- (GLKMatrix4)viewMatrix;
- (GLKMatrix4)projectionMatrix;

- (GLKVector3)convertPoint:(GLKVector3)point toNode:(RZXNode *)node;
- (GLKVector3)convertPoint:(GLKVector3)point fromNode:(RZXNode *)node;

- (GLKVector3)convertScale:(GLKVector3)scale toNode:(RZXNode *)node;
- (GLKVector3)convertScale:(GLKVector3)scale fromNode:(RZXNode *)node;

- (GLKQuaternion)convertRotation:(GLKQuaternion)rotation toNode:(RZXNode *)node;
- (GLKQuaternion)convertRotation:(GLKQuaternion)rotation fromNode:(RZXNode *)node;

- (RZXTransform3D *)convertTransform:(RZXTransform3D *)transform toNode:(RZXNode *)node;
- (RZXTransform3D *)convertTransform:(RZXTransform3D *)transform fromNode:(RZXNode *)node;

@end

#pragma mark - RZXNode + Physics Extensions

@interface RZXNode () <RZXPhysicsObject>

@property (strong, nonatomic) RZXPhysicsBody *physicsBody;

@end

@interface RZXPhysicsBody (RZXNode)

@property (weak, nonatomic, readonly) RZXNode *node;

@end
