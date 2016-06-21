//
//  RZXMeshCollider.m
//  RazePhysics
//
//  Created by Rob Visentin on 6/8/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXMeshCollider.h>
#import <RazePhysics/RZXCollider_Private.h>
#import <RazePhysics/RZXContact_Private.h>

#import <RazePhysics/RZXSphereCollider.h>
#import <RazePhysics/RZXBoxCollider.h>

@implementation RZXMeshCollider {
    RZXHull _untransformedHull;
    RZXBox _untransformedBox; // an AABB
    RZXSphere _untransformedSphere;
}

+ (instancetype)colliderWithConvexMesh:(RZXMesh *)mesh
{
    return [[self alloc] initWithConvexMesh:mesh];
}

- (instancetype)initWithConvexMesh:(RZXMesh *)mesh
{
    if ( (self = [super init]) ) {
        // TODO: store untransformed hull
        _untransformedBox = RZXHullGetAABB(_untransformedHull);
        _untransformedSphere = RZXBoxGetBoundingSphere(_untransformedBox);
    }

    return self;
}

#pragma mark - private

- (RZXBox)boundingBox
{
    // NOTE: since _untransformedBox is an AABB, this is not the min volume OBB of the hull,
    // but this is fine because the boundingBox is used only for approximations
    RZXBox box = _untransformedBox;

    RZXTransform3D *transform = self.worldTransform;

    if ( transform != nil ) {
        RZXBoxTranslate(&box, transform.translation);
        RZXBoxRotate(&box, transform.rotation);
        RZXBoxScale(&box, transform.scale);
    }

    return box;
}

- (RZXSphere)boundingSphere
{
    RZXTransform3D *transform = self.worldTransform ?: [RZXTransform3D transform];

    GLKVector3 scale = transform.scale;

    return (RZXSphere) {
        .center = GLKVector3Add(_untransformedSphere.center, transform.translation),
        .radius = _untransformedSphere.radius * MAX(scale.x, MAX(scale.y, scale.z))
    };
}

- (BOOL)pointInside:(GLKVector3)point
{
    BOOL contains = NO;

    if ( RZXBoxContainsPoint(self.boundingBox, point) ) {
        RZXTransform3D *transform = self.worldTransform;

        if ( transform != nil ) {
            GLKMatrix4 transformMatrix = transform.modelMatrix;
            contains = RZXHullContainsPoint(_untransformedHull, point, &transformMatrix);
        }
        else {
            contains = RZXHullContainsPoint(_untransformedHull, point, NULL);
        }
    }

    return contains;
}

- (RZXContact *)generateContact:(RZXCollider *)other
{
    RZXContact *contact = nil;
    RZXContactData contactData;

    if ( RZXSphereIntersectsSphere(self.boundingSphere, other.boundingSphere, NULL) ) {
        RZXTransform3D *transform = self.worldTransform;

        RZXTRS trs = (RZXTRS) {
            .transform = transform.modelMatrix,
            .rotation = transform.rotation
        };

        RZXTRS *trsPtr = (transform != nil) ? &trs : NULL;

        if ( [other isKindOfClass:[RZXBoxCollider class]] ) {
            if ( RZXHullIntersectsBox(_untransformedHull, trsPtr, other.boundingBox, &contactData) ) {
                contact = [[RZXContact alloc] initWithContactData:contactData];
            }
        }
        else if ( [other isKindOfClass:[RZXSphereCollider class]] ) {
            if ( RZXHullIntersectsSphere(_untransformedHull, trsPtr, other.boundingSphere, &contactData) ) {
                contact = [[RZXContact alloc] initWithContactData:contactData];
            }
        }
        else if ( [other isKindOfClass:[RZXMeshCollider class]] ) {
            RZXTransform3D *otherTransform = other.worldTransform;

            RZXTRS otherTrs = (RZXTRS) {
                .transform = otherTransform.modelMatrix,
                .rotation = otherTransform.rotation
            };

            RZXTRS *otherTrsPtr = (otherTransform != nil) ? &otherTrs : NULL;
            RZXHull otherHull = ((RZXMeshCollider *)other)->_untransformedHull;

            if ( RZXHullIntersectsHull(_untransformedHull, trsPtr, otherHull, otherTrsPtr, &contactData) ) {
                contact = [[RZXContact alloc] initWithContactData:contactData];
            }
        }
    }

    return contact;
}

@end
