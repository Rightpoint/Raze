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

#import <RazeCore/RZXMesh.h>

#import <RazePhysics/RZXSphereCollider.h>
#import <RazePhysics/RZXBoxCollider.h>

@implementation RZXMeshCollider {
    NSData *_vertexData;
    RZXTransform3D *_transform;

    RZXHull _untransformedHull;
    RZXBox _untransformedBox; // an AABB
    RZXSphere _untransformedSphere;
}

+ (instancetype)colliderWithConvexMesh:(RZXMesh *)mesh
{
    return [[self alloc] initWithConvexMesh:mesh];
}

+ (instancetype)colliderWithConvexMesh:(RZXMesh *)mesh transform:(RZXTransform3D *)transform
{
    return [[self alloc] initWithConvexMesh:mesh transform:transform];
}

- (instancetype)initWithConvexMesh:(RZXMesh *)mesh
{
    return [self initWithConvexMesh:mesh transform:nil];
}

- (instancetype)initWithConvexMesh:(RZXMesh *)mesh transform:(RZXTransform3D *)transform
{
    GLsizei vertexSize = mesh.vertexSize;
    NSUInteger positionOffset = [mesh offsetOfAttribute:kRZXVertexAttribPosition];

    if ( vertexSize <= 0 ) {
        RZXLog(@"RZXMeshCollider failed to intialize with %@, because the mesh vertex size was 0.", mesh);
        self = nil;
    }
    else if ( positionOffset == NSNotFound ) {
        RZXLog(@"RZXMeshCollider failed to intialize with %@, because the mesh did not have kRZXVertexAttribPosition as a vertex attribute.", mesh);
        self = nil;
    }
    else if ( (self = [super init]) ) {
        _vertexData = [mesh vertices];

        _untransformedHull = (RZXHull) {
            .points = ((const char *)_vertexData.bytes) + positionOffset,
            .n = (GLsizei)_vertexData.length / vertexSize,
            .stride = vertexSize
        };

        _untransformedBox = RZXHullGetAABB(_untransformedHull);
        _untransformedSphere = RZXBoxGetBoundingSphere(_untransformedBox);

        _transform = transform;
    }
    
    return self;
}

#pragma mark - private

- (RZXTransform3D *)worldTransform
{
    RZXTransform3D *world = [super worldTransform];

    if ( _transform != nil ) {
        world = [_transform transformedBy:world];
    }

    return world;
}

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
