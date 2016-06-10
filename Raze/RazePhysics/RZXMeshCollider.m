//
//  RZXMeshCollider.m
//  RazePhysics
//
//  Created by Rob Visentin on 6/8/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXMeshCollider.h>
#import <RazePhysics/RZXCollider_Private.h>
#import <RazePhysics/RZXGJK.h>

#import <RazePhysics/RZXSphereCollider.h>
#import <RazePhysics/RZXBoxCollider.h>

@implementation RZXMeshCollider {
    RZXHull _untransformedHull;
    RZXBox _untransformedBox;
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
        _untransformedBox = RZXHullGetOBB(_untransformedHull);
        _untransformedSphere = RZXBoxGetBoundingSphere(_untransformedBox);
    }

    return self;
}

#pragma mark - private

- (RZXBox)boundingBox
{
    RZXTransform3D *transform = self.body.representedObject.worldTransform ?: [RZXTransform3D transform];

    RZXBox box = _untransformedBox;

    RZXBoxTranslate(&box, transform.translation);
    RZXBoxRotate(&box, transform.rotation);
    RZXBoxScale(&box, transform.scale);

    return box;
}

- (RZXSphere)boundingSphere
{
    RZXTransform3D *transform = self.body.representedObject.worldTransform ?: [RZXTransform3D transform];

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
        RZXTransform3D *transform = self.body.representedObject.worldTransform;

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

    if ( RZXSphereIntersectsSphere(self.boundingSphere, other.boundingSphere, NULL) ) {
        if ( [other isKindOfClass:[RZXBoxCollider class]] ) {
            // TODO
        }
        else if ( [other isKindOfClass:[RZXSphereCollider class]] ) {
            // TODO
        }
        else if ( [other isKindOfClass:[RZXMeshCollider class]] ) {
            // TODO
        }
    }

    return contact;
}

@end
