//
//  RZXSphereCollider.m
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXSphereCollider.h>
#import <RazePhysics/RZXCollider_Private.h>

#import <RazePhysics/RZXBoxCollider.h>

@implementation RZXSphereCollider

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
        _radius = radius;
        _center = center;
    }

    return self;
}

#pragma mark - private

- (RZXSphere)boundingSphere
{
    RZXTransform3D *transform = self.body.representedObject.worldTransform ?: [RZXTransform3D transform];

    GLKVector3 scale = transform.scale;

    return (RZXSphere) {
        .center = GLKVector3Add(_center, transform.translation),
        .radius = _radius * MAX(scale.x, MAX(scale.y, scale.z))
    };
}

- (RZXBox)boundingBox
{
    RZXSphere boundingSphere = self.boundingSphere;

    GLKVector3 boxMin = GLKVector3Make(boundingSphere.center.x - 0.5 * boundingSphere.radius,
                                       boundingSphere.center.y - 0.5 * boundingSphere.radius,
                                       boundingSphere.center.z - 0.5 * boundingSphere.radius);

    GLKVector3 boxMax = GLKVector3Make(boundingSphere.center.x + 0.5 * boundingSphere.radius,
                                       boundingSphere.center.y + 0.5 * boundingSphere.radius,
                                       boundingSphere.center.z + 0.5 * boundingSphere.radius);

    return (RZXBox) { .min = boxMin, .max = boxMax };
}

- (BOOL)pointInside:(GLKVector3)point
{
    return RZXSphereContainsPoint(self.boundingSphere, point);
}

- (RZXContact *)generateContact:(RZXCollider *)other
{
    RZXContact *contact = nil;

    RZXSphere bounds = self.boundingSphere;

    if ( [other isKindOfClass:[RZXBoxCollider class]] ) {
        RZXBox otherBounds = other.boundingBox;

        GLKVector3 nearestPoint = RZXBoxGetNearestPoint(otherBounds, bounds.center);
        GLKVector3 diff = GLKVector3Subtract(bounds.center, nearestPoint);

        if ( GLKVector3Length(diff) <= bounds.radius ) {
            contact = [[RZXContact alloc] init];
            contact.normal = GLKVector3Normalize(diff);
        }
    }
    else if ( [other isKindOfClass:[RZXSphereCollider class]] ) {
        RZXSphere otherBounds = other.boundingSphere;

        if ( RZXSphereIntersectsSphere(bounds, otherBounds) ) {
            GLKVector3 diff = GLKVector3Subtract(bounds.center, otherBounds.center);

            contact = [[RZXContact alloc] init];
            contact.normal = GLKVector3Normalize(diff);
        }
    }

    return contact;
}

@end
