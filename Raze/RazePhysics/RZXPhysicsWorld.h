//
//  RZXPhysicsWorld.h
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCollider.h>

@class RZXCollision;

@interface RZXPhysicsWorld : NSObject

- (void)addCollider:(RZXCollider *)collider;
- (void)removeCollider:(RZXCollider *)collider;

- (NSSet *)computeCollisions;

@end

@interface RZXCollision : NSObject

@property (strong, nonatomic) RZXCollider *first;
@property (strong, nonatomic) RZXCollider *second;

@end
