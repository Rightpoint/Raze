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
    RZXTransform3D *transform = self.body.representedObject.worldTransform ?: [RZXTransform3D transform];

    GLKVector3 scale = transform.scale;

    return (RZXSphere) {
        .center = GLKVector3Add(_untransformedSphere.center, transform.translation),
        .radius = _untransformedSphere.radius * MAX(scale.x, MAX(scale.y, scale.z))
    };
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

    RZXSphere bounds = self.boundingSphere;

    if ( [other isKindOfClass:[RZXBoxCollider class]] ) {
        RZXBox otherBounds = other.boundingBox;

        GLKVector3 nearestPoint = RZXBoxGetNearestPoint(otherBounds, bounds.center);
        GLKVector3 diff = GLKVector3Subtract(bounds.center, nearestPoint);
        float dist = GLKVector3Length(diff);

        if ( dist <= bounds.radius ) {
            contact = [[RZXContact alloc] init];
            contact.normal = GLKVector3DivideScalar(diff, dist);
        }
    }
    else if ( [other isKindOfClass:[RZXSphereCollider class]] ) {
        RZXSphere otherBounds = other.boundingSphere;

        GLKVector3 diff = GLKVector3Subtract(bounds.center, otherBounds.center);
        float dist = GLKVector3Length(diff);

        if ( dist <= bounds.radius ) {

            contact = [[RZXContact alloc] init];
            contact.normal = GLKVector3DivideScalar(diff, dist);
        }
    }

    return contact;
}

@end
