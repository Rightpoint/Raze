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
    RZXTransform3D *transform = self.body.representedObject.worldTransform ?: [RZXTransform3D transform];

    RZXBox boundingBox = _untransformedBoundingBox;
    RZXBoxScale(&boundingBox, transform.scale);

    GLKVector3 center = GLKVector3Add(_center, transform.translation);

    return (RZXSphere) {
        .center = center,
        .radius = GLKVector3Distance(center, boundingBox.min)
    };
}

- (RZXBox)boundingBox
{
    RZXTransform3D *transform = self.body.representedObject.worldTransform ?: [RZXTransform3D transform];

    RZXBox boundingBox = _untransformedBoundingBox;

    if ( GLKQuaternionAngle(transform.rotation) == 0.0f ) {
        RZXBoxTranslate(&boundingBox, transform.translation);
        RZXBoxScale(&boundingBox, transform.scale);
    }
    else {
        RZXBoxTransform(&boundingBox, transform.modelMatrix);
    }

    return boundingBox;
}

- (BOOL)pointInside:(GLKVector3)point
{
    return RZXBoxContainsPoint(self.boundingBox, point);
}

- (RZXContact *)generateContact:(RZXCollider *)other
{
    RZXContact *contact = nil;

    if ( [other isKindOfClass:[RZXBoxCollider class]] ) {
        RZXBox bounds = self.boundingBox;
        RZXBox otherBounds = other.boundingBox;

        if ( RZXBoxIntersectsBox(bounds, otherBounds) ) {
            // TODO: compute correct normal and distance
            contact = [[RZXContact alloc] init];
        }
    }
    else if ( [other isKindOfClass:[RZXSphereCollider class]] ) {
        contact = [other generateContact:self];
        contact.normal = GLKVector3Negate(contact.normal);
    }

    return contact;
}

@end
