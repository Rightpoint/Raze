//
//  RZXPhysicsWorld.h
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXUpdateable.h>
#import <RazePhysics/RZXPhysicsBody.h>

@class RZXCollision;

typedef void (^RZXPhysicsBodyEnumeration)(RZXPhysicsBody *body, BOOL *stop);

@interface RZXPhysicsWorld : NSObject <RZXUpdateable>

@property (assign, nonatomic) GLKVector3 gravity;

- (void)addBody:(RZXPhysicsBody *)body;
- (void)removeBody:(RZXPhysicsBody *)body;

- (RZXPhysicsBody *)bodyAtPoint:(GLKVector3)point;

- (void)enumerateBodiesWithBlock:(RZXPhysicsBodyEnumeration)block;
- (void)enumerateBodiesAtPoint:(GLKVector3)point withBlock:(RZXPhysicsBodyEnumeration)block;

@end
