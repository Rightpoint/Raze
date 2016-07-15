//
//  RZXGeometry.m
//  RazePhysics
//
//  Created by Rob Visentin on 6/8/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXGeometry.h>
#import <RazePhysics/RZXGJK.h>

#pragma mark - Lines

bool RZXLineIntersection(RZXLine l1, RZXLine l2, RZXLineIntersectionData *data)
{
    #define NO_INTERSECTION ({ \
        if ( data != NULL ) { \
            data->p = GLKVector3Make(INFINITY, INFINITY, INFINITY); \
            data->t = INFINITY; \
            data->s = INFINITY; \
        } \
        false; \
    })

    GLKVector3 diff = GLKVector3Subtract(l2.p0, l1.p0);

    GLKVector3 v1 = GLKVector3Normalize(l1.v);
    GLKVector3 v2 = GLKVector3Normalize(l2.v);

    // check if lines are parallel
    if ( RZX_IS_ZERO(fabsf(GLKVector3DotProduct(v1, v2)) - 1.0f) ) {
        // check if lines are coincident (intersection at all points)
        float len = GLKVector3Length(diff);
        if ( RZX_IS_ZERO(len) || RZX_IS_ZERO(fabsf(GLKVector3DotProduct(GLKVector3DivideScalar(diff, len), v1)) - 1.0f) ) {
            if ( data != NULL ) {
                data->p = l1.p0;
                data->t = 0.0f;
                data->s = 0.0f;
            }

            return true;
        }
        
        return NO_INTERSECTION;
    }

    // find an axis for which l2 is non-zero
    int a0 = 0;

    if ( l2.v.y != 0.0f ) {
        a0 = 1;
    }
    else if ( l2.v.z != 0.0f ) {
        a0 = 2;
    }

    // solve equations with one of the other 2 axes
    int a1 = (a0 + 3 - 1) % 3;
    int a2 = (a0 + 1) % 3;

    float denom = (l2.v.v[a1] * l1.v.v[a0] - l2.v.v[a0] * l1.v.v[a1]);
    float t = 0.0f;

    // keep track of which axis wasn't solved for
    int au = a2;

    if ( denom != 0.0f ) {
        t = (diff.v[a0] * l2.v.v[a1] - l2.v.v[a0] * diff.v[a1]) / denom;
    }
    else {
        float denom2 = (l2.v.v[a2] * l1.v.v[a0] - l2.v.v[a0] * l1.v.v[a2]);

        if ( denom2 != 0.0f ) {
            t = (diff.v[a0] * l2.v.v[a2] - l2.v.v[a0] * diff.v[a2]) / denom2;
            au = a1;
        }
        else {
            // can't solve either set of equations
            return NO_INTERSECTION;
        }
    }

    // plug t back in to find s
    float s = (-diff.v[a0] + (t * l1.v.v[a0])) / l2.v.v[a0];

    // compute intersection point
    GLKVector3 p = GLKVector3Add(l1.p0, GLKVector3MultiplyScalar(l1.v, t));

    // test the unsolved axis to make sure it matches
    // if is doesn't, the lines are skew
    if ( l2.v.v[au] != 0.0f && !RZX_IS_ZERO((-diff.v[au] + (t * l1.v.v[au])) / l2.v.v[au] - s) ) {
        return NO_INTERSECTION;
    }
    else if ( !RZX_IS_ZERO(l2.p0.v[au] - p.v[au]) ) {
        return NO_INTERSECTION;
    }

    if ( data != NULL ) {
        data->p = p;
        data->t = t;
        data->s = s;
    }

    #undef NO_INTERSECTION

    return true;
}

#pragma mark - Intersection

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
