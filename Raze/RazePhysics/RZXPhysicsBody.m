//
//  RZXPhysicsBody.m
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXPhysicsBody.h>
#import <RazePhysics/RZXCollider_Private.h>

@implementation RZXPhysicsBody

- (void)setCollider:(RZXCollider *)collider
{
    _collider.body = nil;
    _collider = collider;
    _collider.body = self;
}

@end
