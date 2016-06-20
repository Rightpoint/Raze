//
//  RZXPhysicsBody.h
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCollider.h>

@protocol RZXPhysicsObject;

@interface RZXPhysicsBody : NSObject

/**
 *  An identifier for use by your application.
 */
@property (copy, nonatomic) NSString *name;

@property (strong, nonatomic) id<RZXPhysicsObject> representedObject;
@property (strong, nonatomic) RZXCollider *collider;

/**
 *  The physics world that the body exists in.
 */
@property (weak, nonatomic, readonly) RZXPhysicsWorld *world;

/**
 *  The category mask used when testing whether two bodies should collide.
 *  Default is 0xFFFF.
 */
@property (assign, nonatomic) uint32_t categoryMask;

/**
 *  The body colides with another body when other.categoryMask bitwise and-ed with the collisionMask is non-zero.
 *  Default is 0xFFFF, meaning the body will collide with everything.
 */
@property (assign, nonatomic) uint32_t collisionMask;

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
