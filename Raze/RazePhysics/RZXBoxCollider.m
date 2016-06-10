//
//  RZXBoxCollider.m
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXBoxCollider.h>
#import <RazePhysics/RZXCollider_Private.h>
#import <RazePhysics/RZXContact_Private.h>

#import <RazePhysics/RZXSphereCollider.h>
#import <RazePhysics/RZXMeshCollider.h>

@implementation RZXBoxCollider {
    RZXBox _untransformedBox;
}

+ (instancetype)colliderWithSize:(GLKVector3)size
{
    return [[self alloc] initWithSize:size];
}

+ (instancetype)colliderWithSize:(GLKVector3)size center:(GLKVector3)center
{
    return [[self alloc] initWithSize:size center:center];
}

+ (instancetype)colliderWithSize:(GLKVector3)size center:(GLKVector3)center rotation:(GLKQuaternion)rotation
{
    return [[self alloc] initWithSize:size center:center rotation:rotation];
}

- (instancetype)initWithSize:(GLKVector3)size
{
    return [self initWithSize:size center:RZXVector3Zero];
}

- (instancetype)initWithSize:(GLKVector3)size center:(GLKVector3)center
{
    return [self initWithSize:size center:center rotation:GLKQuaternionIdentity];
}

- (instancetype)initWithSize:(GLKVector3)size center:(GLKVector3)center rotation:(GLKQuaternion)rotation
{
    if ( (self = [super init]) ) {
        GLKVector3 halfSize = GLKVector3MultiplyScalar(size, 0.5f);
        _untransformedBox = RZXBoxMake(center, halfSize, rotation);
    }

    return self;
}

- (GLKVector3)size
{
    return RZXBoxGetSize(_untransformedBox);
}

- (GLKVector3)center
{
    return _untransformedBox.center;
}

- (GLKQuaternion)rotation
{
    return RZXBoxGetRotation(_untransformedBox);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    RZXBoxCollider *copy = [super copyWithZone:zone];
    copy->_untransformedBox = _untransformedBox;

    return copy;
}

#pragma mark - private

- (RZXSphere)boundingSphere
{
    return RZXBoxGetBoundingSphere(self.boundingBox);
}

- (RZXBox)boundingBox
{
    RZXTransform3D *transform = self.body.representedObject.worldTransform ?: [RZXTransform3D transform];

    RZXBox box = _untransformedBox;

    RZXBoxTranslate(&box, transform.translation);
    RZXBoxRotate(&box, transform.rotation);
    RZXBoxScale(&box, transform.scale);

    return box;
}

- (BOOL)pointInside:(GLKVector3)point
{
    return RZXBoxContainsPoint(self.boundingBox, point);
}

- (RZXContact *)generateContact:(RZXCollider *)other
{
    RZXContact *contact = nil;
    RZXContactData contactData;

    RZXBox bounds = self.boundingBox;

    if ( [other isKindOfClass:[RZXBoxCollider class]] ) {
        if ( RZXBoxIntersectsBox(bounds, other.boundingBox, &contactData) ) {
            contact = [[RZXContact alloc] initWithContactData:contactData];
        }
    }
    else if ( [other isKindOfClass:[RZXSphereCollider class]] ) {
        if ( RZXBoxIntersectsSphere(bounds, other.boundingSphere, &contactData) ) {
            contact = [[RZXContact alloc] initWithContactData:contactData];
        }
    }
    else if ( [other isKindOfClass:[RZXMeshCollider class]] ) {
        contact = [other generateContact:self];
        contact.normal = GLKVector3Negate(contact.normal);
    }

    return contact;
}

@end
