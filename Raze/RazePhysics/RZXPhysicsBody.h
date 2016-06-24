//
//  RZXPhysicsBody.h
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCollider.h>

@protocol RZXPhysicsObject;

@interface RZXPhysicsBody : NSObject <NSCopying>

/**
 *  An identifier for use by your application.
 */
@property (copy, nonatomic) NSString *name;

/**
 *  The model object that the body represents.
 *  @note If using the `RazeScene` module, the `representedObject` will be an `RZXNode`,
 *  and should not be set directly.
 */
@property (strong, nonatomic) id<RZXPhysicsObject> representedObject;

/**
 *  The collision volume attached to the body that defines the shape of the body.
 *  Default is `nil`.
 */
@property (strong, nonatomic) RZXCollider *collider;

/**
 *  The physics world that the body exists in.
 */
@property (weak, nonatomic, readonly) RZXPhysicsWorld *world;

/**
 *  Mass of the body. 
 *  This can be in any units, as long as all masses in the system are relative and consistant. 
 *  Default is 1.0.
 */
@property (assign, nonatomic) float mass;

/**
 *  Coefficient of restitution for the body. Default is 0.0.
 */
@property (assign, nonatomic) float restitution;

/**
 *  The motion of the body per second. Default is (0.0, 0.0, 0.0).
 */
@property (assign, nonatomic) GLKVector3 velocity;

/**
 *  Whether the body should be affected by forces. Default is YES.
 *  @note Bodies 
 */
@property (assign, nonatomic, getter=isDynamic) BOOL dynamic;

/**
 *  Whether the body should be affected by gravitional force. Default is YES.
 */
@property (assign, nonatomic, getter=isAffectedByGravity) BOOL affectedByGravity;

/**
 *  The set of bodies currently in contact with the receiver.
 *  @note If the receiver does not have a collider attached, then this set will always be empty.
 */
@property (nonatomic, readonly) NSSet *contactedBodies;

+ (instancetype)bodyWithCollider:(RZXCollider *)collider;
- (instancetype)initWithCollider:(RZXCollider *)collider;

- (void)applyImpulse:(GLKVector3)impulse;

@end

@protocol RZXPhysicsObject <NSObject>

@property (nonatomic, readonly) RZXTransform3D *transform;
@property (nonatomic, readonly) RZXTransform3D *worldTransform;

- (void)willSimulatePhysics;
- (void)didSimulatePhysics;

@end
