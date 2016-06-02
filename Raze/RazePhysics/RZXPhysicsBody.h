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

@property (strong, nonatomic) id<RZXPhysicsObject> representedObject;
@property (strong, nonatomic) RZXCollider *collider;

@property (weak, nonatomic, readonly) RZXPhysicsWorld *world;

@property (assign, nonatomic) float mass;
@property (assign, nonatomic) float restitution;
@property (assign, nonatomic) GLKVector3 velocity;

@property (assign, nonatomic, getter=isDynamic) BOOL dynamic;
@property (assign, nonatomic, getter=isAffectedByGravity) BOOL affectedByGravity;

+ (instancetype)bodyWithCollider:(RZXCollider *)collider;
- (instancetype)initWithCollider:(RZXCollider *)collider;

- (void)applyForce:(GLKVector3)force;
- (void)applyImpulse:(GLKVector3)impulse;

@end

@protocol RZXPhysicsObject <NSObject>

@property (nonatomic, readonly) RZXTransform3D *transform;
@property (nonatomic, readonly) RZXTransform3D *worldTransform;

@end
