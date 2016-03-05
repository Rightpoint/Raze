//
//  RZXBoxCollider.m
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXBoxCollider.h>
#import <RazePhysics/RZXCollider_Private.h>

@implementation RZXBoxCollider

+ (instancetype)colliderWithSize:(GLKVector3)size
{
    return [self colliderWithSize:size center:RZXVector3Zero];
}

+ (instancetype)colliderWithSize:(GLKVector3)size center:(GLKVector3)center
{
    return [[self alloc] initWithSize:size center:center];
}

- (instancetype)initWithSize:(GLKVector3)size
{
    return [self initWithSize:size center:RZXVector3Zero];
}

- (instancetype)initWithSize:(GLKVector3)size center:(GLKVector3)center
{
    if ( (self = [super init]) ) {
        _size = size;
        _center = center;
    }

    return self;
}

#pragma mark - private

- (BOOL)willCollideWith:(RZXCollider *)other transform:(RZXTransform3D *)transform
{
    // TODO
    return NO;
}

@end
