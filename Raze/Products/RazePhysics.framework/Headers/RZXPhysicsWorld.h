//
//  RZXPhysicsWorld.h
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXUpdateable.h>
#import <RazePhysics/RZXPhysicsBody.h>
#import <RazePhysics/RZXContact.h>

@class RZXCollision;

@protocol RZXPhysicsWorldDelegate;

typedef void (^RZXPhysicsBodyEnumeration)(RZXPhysicsBody *body, BOOL *stop);

@interface RZXPhysicsWorld : NSObject <RZXUpdateable>

/**
 *  Constant acceleration applied to all physics bodies.
 *  Deault is (0.0, -9.8, 0.0).
 */
@property (assign, nonatomic) GLKVector3 gravity;

@property (weak, nonatomic) id<RZXPhysicsWorldDelegate> delegate;

- (void)addBody:(RZXPhysicsBody *)body;
- (void)removeBody:(RZXPhysicsBody *)body;

- (RZXPhysicsBody *)bodyAtPoint:(GLKVector3)point;

- (void)enumerateBodiesWithBlock:(RZXPhysicsBodyEnumeration)block;
- (void)enumerateBodiesAtPoint:(GLKVector3)point withBlock:(RZXPhysicsBodyEnumeration)block;

@end

@protocol RZXPhysicsWorldDelegate <NSObject>

- (void)contactDidBegin:(RZXContact *)contact;
- (void)contactDidEnd:(RZXContact *)contact;

@end
