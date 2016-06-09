//
//  RZXGeometry.m
//  RazePhysics
//
//  Created by Rob Visentin on 6/8/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXGeometry.h>
#import <RazePhysics/RZXGJK.h>

bool RZXHullContainsPoint(RZXHull h, GLKVector3 p, GLKMatrix4 *transform)
{
    // TODO: implement point in convex hull test
    return false;
}

GLK_INLINE GLKVector3 RZXSphereSupport(RZXSphere sphere, GLKVector3 v)
{
    return GLKVector3Add(sphere.center, GLKVector3MultiplyScalar(v, sphere.radius));
}

// The point in the hull most distant along v is called a "supporting point"
// These are not necessarily unique
// For a polyhedron, a vertex can always be selected as a supporting point
GLK_INLINE GLKVector3 RZXHullSupport(RZXHull hull, GLKVector3 v)
{
    unsigned int idx = 0;
    float maxDot = GLKVector3DotProduct(RZXHullGetPoint(hull, 0), v);

    for ( unsigned int i = 1; i < hull.n; ++i ) {
        float dot = GLKVector3DotProduct(RZXHullGetPoint(hull, i), v);

        if ( dot > maxDot ) {
            maxDot = dot;
            idx = i;
        }
    }

    return RZXHullGetPoint(hull, idx);
}

bool RZXHullIntersectsSphere(RZXHull hull, RZXSphere sphere)
{
    RZXGJKSupport support = ^GLKVector3 (GLKVector3 v) {
        // S(v⃗) = S1(v⃗) − S2(−v⃗)
        return GLKVector3Subtract(RZXHullSupport(hull, v), RZXSphereSupport(sphere, GLKVector3Negate(v)));
    };

    RZXGJK gjk = RZXGJKStart();

    return RZXGJKIntersection(&gjk, support);
}

bool RZXHullIntersectsBox(RZXHull hull, RZXBox box)
{
    GLKVector3 corners[8];
    RZXBoxGetCorners(box, corners);

    RZXHull boxHull = (RZXHull){
        .points = (const void *)corners,
        .n = 8,
        .stride = sizeof(GLKVector3)
    };

    return RZXHullIntersectsHull(hull, boxHull);
}

bool RZXHullIntersectsHull(RZXHull h1, RZXHull h2)
{
    RZXGJKSupport support = ^GLKVector3 (GLKVector3 v) {
        // S(v⃗) = S1(v⃗) − S2(−v⃗)
        return GLKVector3Subtract(RZXHullSupport(h1, v), RZXHullSupport(h2, GLKVector3Negate(v)));
    };
    
    RZXGJK gjk = RZXGJKStart();

    return RZXGJKIntersection(&gjk, support);
}
