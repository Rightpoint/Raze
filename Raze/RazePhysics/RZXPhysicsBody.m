//
//  RZXPhysicsBody.m
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXPhysicsBody.h>
#import <RazePhysics/RZXCollider_Private.h>

@interface RZXPhysicsBody()

// For RZXScene integration
@property (weak, nonatomic) id node;

@end

@implementation RZXPhysicsBody

+ (instancetype)bodyWithCollider:(RZXCollider *)collider
{
    return [[self alloc] initWithCollider:collider];
}

- (instancetype)initWithCollider:(RZXCollider *)collider
{
    if ( (self = [super init]) ) {
        self.collider = collider;
    }
    return self;
}

- (void)setCollider:(RZXCollider *)collider
{
    _collider.body = nil;
    _collider = collider;
    _collider.body = self;
}

@end
