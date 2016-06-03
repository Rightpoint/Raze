//
//  RZXCollider_Private.h
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXUpdateable.h>
#import <RazePhysics/RZXPhysicsBody.h>
#import <RazePhysics/RZXCollider_Private.h>

@interface RZXPhysicsBody () <RZXUpdateable>

@property (weak, nonatomic) RZXPhysicsWorld *world;

@property (nonatomic, readonly) float inverseMass;

- (void)adjustVelocity:(GLKVector3)dv;

- (RZXContact *)generateContact:(RZXPhysicsBody *)other;

@end
