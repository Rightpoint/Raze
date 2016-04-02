//
//  RZXCollider.m
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCollider.h>
#import <RazePhysics/RZXCollider_Private.h>

@implementation RZXCollider

- (instancetype)init
{
    if ( self = [super init] ) {
        _previousTransform = [RZXTransform3D transform];
        _transform = [RZXTransform3D transform];
        _active = YES;
    }

    return self;
}

- (void)setWorldTransform:(RZXTransform3D *)transform
{
    self.transform = transform;
}

#pragma mark - private

- (void)setTransform:(RZXTransform3D *)transform
{
    self.previousTransform = _transform;
    _transform = (transform != nil) ? [transform copy] : [RZXTransform3D transform];
}

- (void)revertToPreviousTransform
{
    _transform = _previousTransform;
}

- (BOOL)pointInside:(GLKVector3)point
{
    return NO;
}

- (BOOL)collidesWith:(RZXCollider *)other
{
    return NO;
}

@end
