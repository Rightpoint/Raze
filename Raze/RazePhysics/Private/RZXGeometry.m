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
GLK_INLINE GLKVector3 RZXHullSupport(RZXHull hull, RZXTRS *trs, GLKVector3 v)
{
    // convert direction to local space if necessary
    if ( trs != NULL ) {
        v = GLKQuaternionRotateVector3(GLKQuaternionInvert(trs->rotation), v);
        v = GLKVector3Normalize(v);
    }

    unsigned int idx = 0;
    float maxDot = GLKVector3DotProduct(RZXHullGetPoint(hull, 0), v);

    for ( unsigned int i = 1; i < hull.n; ++i ) {
        float dot = GLKVector3DotProduct(RZXHullGetPoint(hull, i), v);

        if ( dot > maxDot ) {
            maxDot = dot;
            idx = i;
        }
    }

    GLKVector3 p = RZXHullGetPoint(hull, idx);

    if ( trs != NULL ) {
        // convert to world space
        p = RZXMatrix4TransformVector3(trs->transform, p);
    }

    return p;
}

bool RZXBoxIntersectsBox(RZXBox b1, RZXBox b2, RZXContactData *data)
{
    GLKVector3 corners[8];
    RZXBoxGetCorners(b1, corners);

    RZXHull boxHull = (RZXHull){
        .points = (const void *)corners,
        .n = 8,
        .stride = sizeof(GLKVector3)
    };

    return RZXHullIntersectsBox(boxHull, NULL, b2, data);
}

bool RZXHullIntersectsSphere(RZXHull hull, RZXTRS *trs, RZXSphere sphere, RZXContactData *data)
{
    RZXGJKSupportMapping support = ^RZXGJKSupport (GLKVector3 v) {
        GLKVector3 s1 = RZXHullSupport(hull, trs, v);
        GLKVector3 s2 = RZXSphereSupport(sphere, GLKVector3Negate(v));

        // S(v⃗) = S1(v⃗) − S2(−v⃗)
        return (RZXGJKSupport){ .p = GLKVector3Subtract(s1, s2), .s = s1 };
    };

    RZXGJK gjk = RZXGJKStart();

    if ( RZXGJKIntersection(&gjk, support) ) {
        return RZXGJKGetContactData(&gjk, support, data);
    }
    return false;
}

bool RZXHullIntersectsBox(RZXHull hull, RZXTRS *trs, RZXBox box, RZXContactData *data)
{
    GLKVector3 corners[8];
    RZXBoxGetCorners(box, corners);

    RZXHull boxHull = (RZXHull){
        .points = (const void *)corners,
        .n = 8,
        .stride = sizeof(GLKVector3)
    };

    return RZXHullIntersectsHull(hull, trs, boxHull, NULL, data);
}

bool RZXHullIntersectsHull(RZXHull h1, RZXTRS *t1, RZXHull h2, RZXTRS *t2, RZXContactData *data)
{
    RZXGJKSupportMapping support = ^RZXGJKSupport (GLKVector3 v) {
        GLKVector3 s1 = RZXHullSupport(h1, t1, v);
        GLKVector3 s2 = RZXHullSupport(h2, t2, GLKVector3Negate(v));

        // S(v⃗) = S1(v⃗) − S2(−v⃗)
        return (RZXGJKSupport){ .p = GLKVector3Subtract(s1, s2), .s = s1 };
    };
    
    RZXGJK gjk = RZXGJKStart();

    if ( RZXGJKIntersection(&gjk, support) ) {
        return RZXGJKGetContactData(&gjk, support, data);
    }
    return false;
}
