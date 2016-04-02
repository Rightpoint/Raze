//
//  RZXBoxCollider.m
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXBoxCollider.h>
#import <RazePhysics/RZXCollider_Private.h>

#import <RazePhysics/RZXSphereCollider.h>

@implementation RZXBoxCollider {
    RZXBox _untransformedBoundingBox;
}

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

        GLKVector3 halfSize = GLKVector3MultiplyScalar(size, 0.5f);

        _untransformedBoundingBox = (RZXBox) {
            .min = GLKVector3Subtract(center, halfSize),
            .max = GLKVector3Add(center, halfSize)
        };
    }

    return self;
}

#pragma mark - private

- (RZXSphere)boundingSphere
{
    RZXBox boundingBox = _untransformedBoundingBox;
    RZXBoxScale(&boundingBox, self.transform.scale);

    GLKVector3 center = GLKVector3Add(_center, self.transform.translation);

    return (RZXSphere) {
        .center = center,
        .radius = GLKVector3Distance(center, boundingBox.min)
    };
}

- (RZXBox)boundingBox
{
    RZXBox boundingBox = _untransformedBoundingBox;

    if ( GLKQuaternionAngle(self.transform.rotation) == 0.0f ) {
        RZXBoxTranslate(&boundingBox, self.transform.translation);
        RZXBoxScale(&boundingBox, self.transform.scale);
    }
    else {
        RZXBoxTransform(&boundingBox, self.transform.modelMatrix);
    }

    return boundingBox;
}

- (BOOL)pointInside:(GLKVector3)point
{
    return RZXBoxContainsPoint(self.boundingBox, point);
}

- (BOOL)collidesWith:(RZXCollider *)other
{
    BOOL collides = NO;

    if ( [other isKindOfClass:[RZXBoxCollider class]] ) {
        collides = RZXBoxIntersectsBox(self.boundingBox, other.boundingBox);
    }
    else if ( [other isKindOfClass:[RZXSphereCollider class]] ) {
        collides = RZXBoxIntersectsSphere(self.boundingBox, other.boundingSphere);
    }

    return collides;
}

@end
