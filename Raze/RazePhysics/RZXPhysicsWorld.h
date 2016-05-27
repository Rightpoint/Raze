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

- (void)addBody:(RZXPhysicsBody *)body;
- (void)removeBody:(RZXPhysicsBody *)body;

- (RZXPhysicsBody *)bodyAtPoint:(GLKVector3)point;

- (void)enumerateBodiesWithBlock:(RZXPhysicsBodyEnumeration)block;
- (void)enumerateBodiesAtPoint:(GLKVector3)point withBlock:(RZXPhysicsBodyEnumeration)block;

- (NSSet *)computeCollisions;

@end

@interface RZXCollision : NSObject

@property (strong, nonatomic) RZXPhysicsBody *first;
@property (strong, nonatomic) RZXPhysicsBody *second;

@end
