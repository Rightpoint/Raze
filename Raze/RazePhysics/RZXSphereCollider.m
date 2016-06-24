//
//  RZXSphereCollider.m
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXSphereCollider.h>
#import <RazePhysics/RZXCollider_Private.h>
#import <RazePhysics/RZXContact_Private.h>

#import <RazePhysics/RZXBoxCollider.h>
#import <RazePhysics/RZXMeshCollider.h>

@implementation RZXSphereCollider {
    RZXSphere _untransformedSphere;
}

+ (instancetype)colliderWithRadius:(float)radius
{
    return [self colliderWithRadius:radius center:RZXVector3Zero];
}

+ (instancetype)colliderWithRadius:(float)radius center:(GLKVector3)center
{
    return [[self alloc] initWithRadius:radius center:center];
}

- (instancetype)initWithRadius:(float)radius
{
    return [self initWithRadius:radius center:RZXVector3Zero];
}

- (instancetype)initWithRadius:(float)radius center:(GLKVector3)center
{
    if ( (self = [super init]) ) {
        _untransformedSphere = (RZXSphere) {
            .center = center,
            .radius = radius
        };
    }

    return self;
}

- (GLKVector3)center
{
    return _untransformedSphere.center;
}

- (float)radius
{
    return _untransformedSphere.radius;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    RZXSphereCollider *copy = [super copyWithZone:zone];
    copy->_untransformedSphere = _untransformedSphere;

    return copy;
}

#pragma mark - private

- (RZXSphere)boundingSphere
{
    RZXTransform3D *transform = self.worldTransform;

    RZXSphere sphere = _untransformedSphere;

    if ( transform != nil ) {
        RZXSphereScale(&sphere, transform.scale);
        RZXSphereTranslate(&sphere, transform.translation);
    }

    return sphere;
}

- (RZXBox)boundingBox
{
    RZXSphere boundingSphere = self.boundingSphere;

    GLKVector3 boxRadius = GLKVector3Make(boundingSphere.radius, boundingSphere.radius, boundingSphere.radius);

    return RZXBoxMakeAxisAligned(boundingSphere.center, boxRadius);
}

- (BOOL)pointInside:(GLKVector3)point
{
    return RZXSphereContainsPoint(self.boundingSphere, point);
}

- (RZXContact *)generateContact:(RZXCollider *)other
{
    RZXContact *contact = nil;
    RZXContactData contactData;

    RZXSphere bounds = self.boundingSphere;

    if ( [other isKindOfClass:[RZXBoxCollider class]] ) {
        contact = [other generateContact:self];
        contact.normal = GLKVector3Negate(contact.normal);
    }
    else if ( [other isKindOfClass:[RZXSphereCollider class]] ) {
        if ( RZXSphereIntersectsSphere(bounds, other.boundingSphere, &contactData) ) {
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
