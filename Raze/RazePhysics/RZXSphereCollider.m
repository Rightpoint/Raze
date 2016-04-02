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
    GLKVector3 scale = self.transform.scale;

    return (RZXSphere) {
        .center = GLKVector3Add(_center, self.transform.translation),
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

- (BOOL)collidesWith:(RZXCollider *)other
{
    BOOL collides = NO;

    if ( [other isKindOfClass:[RZXBoxCollider class]] ) {
        collides = RZXSphereIntersectsBox(self.boundingSphere, other.boundingBox);
    }
    else if ( [other isKindOfClass:[RZXSphereCollider class]] ) {
        collides = RZXSphereIntersectsSphere(self.boundingSphere, other.boundingSphere);
    }

    return collides;
}

@end
