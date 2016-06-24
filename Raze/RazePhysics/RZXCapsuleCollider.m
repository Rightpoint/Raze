//
//  RZXCapsuleCollider.h
//  RazePhysics
//
//  Created by Rob Visentin on 6/24/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCapsuleCollider.h>
#import <RazePhysics/RZXCollider_Private.h>
#import <RazePhysics/RZXContact_Private.h>

#import <RazePhysics/RZXSphereCollider.h>
#import <RazePhysics/RZXBoxCollider.h>
#import <RazePhysics/RZXMeshCollider.h>

@interface RZXCapsuleCollider ()

@property (nonatomic, readonly) RZXCapsule transformedCapsule;

@end

@implementation RZXCapsuleCollider {
    RZXCapsule _untransformedCapsule;
}

+ (instancetype)colliderWithAxis:(GLKVector3)axis radius:(float)radius
{
    return [self colliderWithAxis:axis radius:radius center:RZXVector3Zero];
}

+ (instancetype)colliderWithAxis:(GLKVector3)axis radius:(float)radius center:(GLKVector3)center
{
    return [[self alloc] initWithAxis:axis radius:radius center:center];
}

- (instancetype)initWithAxis:(GLKVector3)axis radius:(float)radius
{
    return [self initWithAxis:axis radius:radius center:RZXVector3Zero];
}

- (instancetype)initWithAxis:(GLKVector3)axis radius:(float)radius center:(GLKVector3)center
{
    if ( (self = [super init]) ) {
        _untransformedCapsule = (RZXCapsule) {
            .center = center,
            .halfAxis = axis,
            .radius = radius
        };
    }

    return self;
}

- (GLKVector3)center
{
    return _untransformedCapsule.center;
}

- (GLKVector3)axis
{
    return _untransformedCapsule.halfAxis;
}

- (float)radius
{
    return _untransformedCapsule.radius;
}

#pragma mark - private

- (RZXCapsule)transformedCapsule
{
    RZXTransform3D *transform = self.worldTransform;

    RZXCapsule capsule = _untransformedCapsule;

    if ( transform != nil ) {
        RZXCapsuleScale(&capsule, transform.scale);
        RZXCapsuleRotate(&capsule, transform.rotation);
        RZXCapsuleTranslate(&capsule, transform.translation);
    }

    return capsule;
}

- (RZXSphere)boundingSphere
{
    RZXTransform3D *transform = self.worldTransform;

    RZXSphere sphere = RZXCapsuleGetBoundingSphere(_untransformedCapsule);

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
    return RZXCapsuleContainsPoint(self.transformedCapsule, point);
}

- (RZXContact *)generateContact:(RZXCollider *)other
{
    RZXContact *contact = nil;
    RZXContactData contactData;

    RZXCapsule bounds = self.transformedCapsule;

    if ( [other isKindOfClass:[RZXBoxCollider class]] ) {
        contact = [other generateContact:self];
        contact.normal = GLKVector3Negate(contact.normal);
    }
    else if ( [other isKindOfClass:[RZXSphereCollider class]] ) {
        if ( RZXCapsuleIntersectsSphere(bounds, other.boundingSphere, &contactData) ) {
            contact = [[RZXContact alloc] initWithContactData:contactData];
        }
    }
    else if ( [other isKindOfClass:[RZXCapsuleCollider class]] ) {
        // TODO
    }
    else if ( [other isKindOfClass:[RZXMeshCollider class]] ) {
        contact = [other generateContact:self];
        contact.normal = GLKVector3Negate(contact.normal);
    }

    return contact;
}

@end
