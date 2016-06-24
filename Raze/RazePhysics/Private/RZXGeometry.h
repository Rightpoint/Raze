//
//  RZXGeometry.h
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#ifndef _RZXGeometry_h
#define _RZXGeometry_h

#include <RazeCore/RZXMath.h>

#pragma mark - Definitions

static float const kRZXFloatEpsilon = 1e-5;

typedef struct _RZXLineSegment {
    GLKVector3 p1, p2;
} RZXLineSegment;

typedef struct _RZXLine {
    GLKVector3 p0, v;  // line of the form p0 + vt
} RZXLine;

typedef struct _RZXSphere {
    GLKVector3 center;
    float radius;
} RZXSphere;

typedef struct _RZXBox {
    GLKVector3 center;
    GLKVector3 radius;
    GLKVector3 axes[3]; // orthonormal vectors storing the xyz axes transformed to local space
} RZXBox;

typedef struct _RZXHull {
    const void *points;
    unsigned int n;
    size_t stride;
} RZXHull;

typedef struct _RZXTRS {
    GLKMatrix4 transform;   // the full TRS transform matrix
    GLKQuaternion rotation; // just the rotation component of the transform
} RZXTRS;

typedef struct _RZXContactData {
    GLKVector3 point;   // contact point (NOT YET IMPLEMENTED)
    GLKVector3 normal;  // collision normal
    float distance;     // penetration distance
} RZXContactData;

#pragma mark - Lines

GLK_INLINE GLKVector3 RZXLineGetIntersection(RZXLine l1, RZXLine l2, float *t, float *s)
{
    if ( fabsf(GLKVector3DotProduct(l1.v, l2.v)) == GLKVector3Length(l1.v) * GLKVector3Length(l2.v) ) {
        // lines are parallel, so no intersection
        *t = INFINITY;
        *s = INFINITY;
        return GLKVector3Make(INFINITY, INFINITY, INFINITY);
    }

    GLKVector3 diff = GLKVector3Subtract(l2.p0, l1.p0);

    // find an axis for which l2 is non-zero
    int a0 = 0;

    if ( l2.v.y != 0.0f ) {
        a0 = 1;
    }
    else if ( l2.v.z != 0.0f ) {
        a0 = 2;
    }

    // solve equations for other 2 axes
    int a1 = (a0 + 3 - 1) % 3;
    int a2 = (a0 + 1) % 3;

    float denom = (l2.v.v[a1] * l1.v.v[a0] - l2.v.v[a0] * l1.v.v[a1]);

    if ( denom != 0.0f ) {
        *t = (diff.v[a0] * l2.v.v[a1] - l2.v.v[a0] * diff.v[a1]) / denom;
    }
    else {
        float denom2 = (l2.v.v[a2] * l1.v.v[a0] - l2.v.v[a0] * l1.v.v[a2]);

        if ( denom2 != 0.0f ) {
            *t = (diff.v[a0] * l2.v.v[a2] - l2.v.v[a0] * diff.v[a2]) / denom2;
        }
        else {
            // lines are skew, no intersection
            *t = INFINITY;
            *s = INFINITY;
            return GLKVector3Make(INFINITY, INFINITY, INFINITY);
        }
    }

    // plug t back in to find s
    *s = (-diff.v[a0] + (*t * l1.v.v[a0])) / l2.v.v[a0];

    return GLKVector3Add(GLKVector3MultiplyScalar(l1.v, *t), l1.p0);
}

#pragma mark - Spheres

GLK_INLINE bool RZXSphereContainsPoint(RZXSphere s, GLKVector3 p)
{
    return (GLKVector3Distance(s.center, p) <= s.radius);
}

GLK_INLINE void RZXSphereTranslate(RZXSphere *s, GLKVector3 t)
{
    s->center = GLKVector3Add(s->center, t);
}

GLK_INLINE void RZXSphereScale(RZXSphere *sphere, GLKVector3 scale)
{
    sphere->radius = sphere->radius * MAX(fabsf(scale.x), MAX(fabsf(scale.y), fabsf(scale.z)));
}

GLK_INLINE void RZXSphereScaleRelative(RZXSphere *sphere, GLKVector3 scale)
{
    RZXSphereScale(sphere, scale);

    // adjust the center relative to the origin
    sphere->center = GLKVector3Multiply(sphere->center, scale);
}

GLK_INLINE bool RZXSphereIntersectsSphere(RZXSphere s1, RZXSphere s2, RZXContactData *data)
{
    GLKVector3 diff = GLKVector3Subtract(s1.center, s2.center);
    float dist = GLKVector3Length(diff);

    if ( dist <= s1.radius + s2.radius ) {
        if ( data != NULL) {
            data->normal = GLKVector3DivideScalar(diff, dist);
            data->distance = (s1.radius - s2.radius - dist);
        }
        
        return true;
    }

    return false;
}

#pragma mark - Boxes

GLK_INLINE GLKVector3 RZXBoxGetSize(RZXBox b)
{
    return GLKVector3MultiplyScalar(b.radius, 2.0f);
}

GLK_INLINE GLKQuaternion RZXBoxGetRotation(RZXBox b)
{
    GLKMatrix3 mat = GLKMatrix3Identity;

    for ( int c = 0; c < 3; ++c ) {
        for ( int r = 0; r < 3; ++r ) {
            mat.m[3 * c + r] = GLKVector3DotProduct(b.axes[c], b.axes[r]);
        }
    }

    return GLKQuaternionMakeWithMatrix3(mat);
}

GLK_INLINE void RZXBoxGetCorners(RZXBox b, GLKVector3 *corners)
{
    GLKVector3 r = b.radius;

    GLKMatrix3 basis = GLKMatrix3MakeWithColumns(b.axes[0], b.axes[1], b.axes[2]);

    GLKVector3 radii[] = {
        // front
        GLKVector3Make(+r.x, -r.y, +r.z),
        GLKVector3Make(+r.x, +r.y, +r.z),
        GLKVector3Make(-r.x, +r.y, +r.z),
        GLKVector3Make(-r.x, -r.y, +r.z),

        //back
        GLKVector3Make(+r.x, -r.y, -r.z),
        GLKVector3Make(+r.x, +r.y, -r.z),
        GLKVector3Make(-r.x, +r.y, -r.z),
        GLKVector3Make(-r.x, -r.y, -r.z)
    };

    for ( int i = 0; i < 8; ++i ) {
        corners[i] = GLKVector3Add(b.center, GLKMatrix3MultiplyVector3(basis, radii[i]));
    }
}

GLK_INLINE GLKVector3 RZXBoxGetNearestPoint(RZXBox b, GLKVector3 p)
{
    // From Christer Ericson's Real-Time Collision Detection, p.133.

    GLKVector3 dir = GLKVector3Subtract(p, b.center);
    GLKVector3 nearest = b.center;

    for ( int i = 0; i < 3; ++i ) {
        float dist = GLKVector3DotProduct(dir, b.axes[i]);
        dist = MAX(-b.radius.v[i], MIN(dist, b.radius.v[i]));

        // walk along the axis to the edge of the box
        nearest = GLKVector3Add(nearest, GLKVector3MultiplyScalar(b.axes[i], dist));
    }

    return nearest;
}

GLK_INLINE RZXSphere RZXBoxGetBoundingSphere(RZXBox box)
{
    GLKVector3 halfDiagonal = RZXVector3Zero;

    for ( int i = 0; i < 3; ++i ) {
        halfDiagonal = GLKVector3Add(halfDiagonal, GLKVector3MultiplyScalar(box.axes[i], box.radius.v[i]));
    }

    return (RZXSphere) {
        .center = box.center,
        .radius = GLKVector3Length(halfDiagonal)
    };
}

GLK_INLINE bool RZXBoxContainsPoint(RZXBox b, GLKVector3 p)
{
    GLKVector3 diff = GLKVector3Subtract(p, b.center);

    for ( int i = 0; i < 3; ++i ) {
        if ( fabsf(GLKVector3DotProduct(diff, b.axes[i])) > b.radius.v[i] ) {
            return false;
        }
    }

    return true;
}

GLK_INLINE void RZXBoxTranslate(RZXBox *b, GLKVector3 trans)
{
    b->center = GLKVector3Add(b->center, trans);
}

GLK_INLINE void RZXBoxScale(RZXBox *b, GLKVector3 scale)
{
    b->radius = GLKVector3Multiply(b->radius, scale);
}

GLK_INLINE void RZXBoxRotate(RZXBox *b, GLKQuaternion q)
{
    for ( int i = 0; i < 3; ++i ) {
        b->axes[i] = GLKVector3Normalize(GLKQuaternionRotateVector3(q, b->axes[i]));
    }
}

GLK_INLINE RZXBox RZXBoxMakeAxisAligned(GLKVector3 center, GLKVector3 r)
{
    RZXBox b = (RZXBox) {
        .center = center,
        .radius = r,
    };

    for ( int i = 0; i < 3; ++i ) {
        b.axes[i] = GLKMatrix3GetRow(GLKMatrix3Identity, i);
    }

    return b;
}

GLK_INLINE RZXBox RZXBoxMake(GLKVector3 c, GLKVector3 r, GLKQuaternion q)
{
    RZXBox b = RZXBoxMakeAxisAligned(c, r);
    RZXBoxRotate(&b, q);
    return b;
}

GLK_INLINE bool RZXBoxIntersectsSphere(RZXBox b, RZXSphere s, RZXContactData *data)
{
    GLKVector3 nearestPoint = RZXBoxGetNearestPoint(b, s.center);
    GLKVector3 diff = GLKVector3Subtract(nearestPoint, s.center);
    float dist = GLKVector3Length(diff);

    if ( dist <= s.radius ) {
        if ( data != NULL ) {
            data->normal = GLKVector3DivideScalar(diff, dist);
            data->distance = (s.radius - dist);
        }

        return true;
    }

    return false;
}

GLK_EXTERN bool RZXBoxIntersectsBox(RZXBox b1, RZXBox b2, RZXContactData *data);

#pragma mark - Hulls

GLK_INLINE GLKVector3 RZXHullGetPoint(RZXHull h, unsigned int idx)
{
    const char *point = ((const char *)h.points) + idx * h.stride;
    return *(GLKVector3 *)point;
}

GLK_INLINE RZXBox RZXHullGetAABB(RZXHull hull)
{
    GLKVector3 min = RZXHullGetPoint(hull, 0);
    GLKVector3 max = RZXHullGetPoint(hull, 0);

    for ( unsigned int i = 1; i < hull.n; ++i ) {
        GLKVector3 p = RZXHullGetPoint(hull, i);

        min = GLKVector3Minimum(min, p);
        max = GLKVector3Maximum(max, p);
    }

    GLKVector3 size = GLKVector3Subtract(max, min);
    GLKVector3 radius = GLKVector3MultiplyScalar(size, 0.5f);

    return RZXBoxMakeAxisAligned(GLKVector3Add(min, radius), radius);
}

GLK_EXTERN bool RZXHullContainsPoint(RZXHull hull, GLKVector3 p, GLKMatrix4 *transform);

GLK_EXTERN bool RZXHullIntersectsSphere(RZXHull hull, RZXTRS *trs, RZXSphere sphere, RZXContactData *data);
GLK_EXTERN bool RZXHullIntersectsBox(RZXHull hull, RZXTRS *trs, RZXBox box, RZXContactData *data);
GLK_EXTERN bool RZXHullIntersectsHull(RZXHull h1, RZXTRS *t1, RZXHull h2, RZXTRS *t2, RZXContactData *data);

#endif
