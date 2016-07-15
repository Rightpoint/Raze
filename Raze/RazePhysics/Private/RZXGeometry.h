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

#define RZX_IS_ZERO(f) (fabsf(f) < kRZXFloatEpsilon)

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

typedef struct _RZXCapsule {
    GLKVector3 center;
    GLKVector3 halfAxis;
    float radius;
} RZXCapsule;

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

typedef struct _RZXLineIntersectionData {
    GLKVector3 p;
    float t, s;
} RZXLineIntersectionData;

#pragma mark - Lines

GLK_INLINE GLKVector3 RZXLineSegmentGetDirection(RZXLineSegment s)
{
    return GLKVector3Subtract(s.p2, s.p1);
}

GLK_INLINE GLKVector3 RZXLineSegmentGetNearestPoint(RZXLineSegment s, GLKVector3 p)
{
    GLKVector3 v = RZXLineSegmentGetDirection(s);
    GLKVector3 vp = GLKVector3Subtract(p, s.p1);

    float vdvp = GLKVector3DotProduct(v, vp);

    if ( vdvp <= 0.0f ) {
        // p lies before p1 on the line
        return s.p1;
    }
    else {
        float vdv = GLKVector3DotProduct(v, v);

        if ( vdv <= vdvp ) {
            return s.p2;
        }
        else {
            // p lies between p1 and p2, so project onto the segment
            float t = (vdvp / vdv);
            return GLKVector3Add(s.p1, GLKVector3MultiplyScalar(v, t));
        }
    }
}

// Adapted from http://paulbourke.net/geometry/pointlineplane/lineline.c
GLK_INLINE RZXLineSegment RZXLineSegmentConnect(RZXLineSegment s1, RZXLineSegment s2)
{
    GLKVector3 dir1 = RZXLineSegmentGetDirection(s1);
    GLKVector3 dir2 = RZXLineSegmentGetDirection(s2);
    GLKVector3 v = GLKVector3Subtract(s1.p1, s2.p1);

    float dot11 = GLKVector3DotProduct(dir1, dir1);
    float dot12 = GLKVector3DotProduct(dir1, dir2);
    float dot22 = GLKVector3DotProduct(dir2, dir2);
    float dot1v = GLKVector3DotProduct(dir1, v);
    float dot2v = GLKVector3DotProduct(dir2, v);

    float denom = (dot11 * dot22 - dot12 * dot12);

    // ensure non-zero denominator for parallel lines
    if ( RZX_IS_ZERO(denom) ) {
        denom = kRZXFloatEpsilon;
    }

    float numer = dot2v * dot12 - dot1v * dot22;

    float t = (numer / denom);
    float s = (dot2v + dot12 * t) / dot22;

    return (RZXLineSegment) {
        .p1 = GLKVector3Add(s1.p1, GLKVector3MultiplyScalar(dir1, t)),
        .p2 = GLKVector3Add(s2.p1, GLKVector3MultiplyScalar(dir2, s))
    };
}

// NOTE: does not handle degenerate lines (v = (0, 0, 0))
GLK_EXTERN bool RZXLineIntersection(RZXLine l1, RZXLine l2, RZXLineIntersectionData *data);

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
    GLKVector3 v = GLKVector3Subtract(s1.center, s2.center);
    float dist = GLKVector3Length(v);

    if ( dist <= s1.radius + s2.radius ) {
        if ( data != NULL) {
            data->normal = GLKVector3DivideScalar(v, dist);
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

#pragma mark - Capsules

GLK_INLINE RZXLineSegment RZXCapsuleGetAxis(RZXCapsule capsule)
{
    return (RZXLineSegment) {
        .p1 = GLKVector3Subtract(capsule.center, capsule.halfAxis),
        .p2 = GLKVector3Add(capsule.center, capsule.halfAxis)
    };
}

GLK_INLINE RZXSphere RZXCapsuleGetBoundingSphere(RZXCapsule capsule)
{
    return (RZXSphere) {
        .center = capsule.center,
        .radius = GLKVector3Length(capsule.halfAxis) + capsule.radius
    };
}

GLK_INLINE bool RZXCapsuleContainsPoint(RZXCapsule c, GLKVector3 p)
{
    RZXLineSegment axis = RZXCapsuleGetAxis(c);
    GLKVector3 nearest = RZXLineSegmentGetNearestPoint(axis, p);
    return (GLKVector3Distance(nearest, p) <= c.radius);
}

GLK_INLINE void RZXCapsuleTranslate(RZXCapsule *c, GLKVector3 trans)
{
    c->center = GLKVector3Add(c->center, trans);
}

GLK_INLINE void RZXCapsuleScale(RZXCapsule *c, GLKVector3 scale)
{
    c->halfAxis = GLKVector3Multiply(c->halfAxis, scale);
    c->radius = c->radius * MAX(fabsf(scale.x), MAX(fabsf(scale.y), fabsf(scale.z)));
}

GLK_INLINE void RZXCapsuleRotate(RZXCapsule *c, GLKQuaternion q)
{
    c->halfAxis = GLKQuaternionRotateVector3(GLKQuaternionNormalize(q), c->halfAxis);
}

GLK_INLINE bool RZXCapsuleIntersectsSphere(RZXCapsule c, RZXSphere s, RZXContactData *data)
{
    RZXLineSegment axis = RZXCapsuleGetAxis(c);
    GLKVector3 nearestPoint = RZXLineSegmentGetNearestPoint(axis, s.center);

    GLKVector3 v = GLKVector3Subtract(s.center, nearestPoint);
    float dist = GLKVector3Length(v);

    if( dist <= c.radius + s.radius ) {
        if ( data != NULL) {
            data->normal = GLKVector3DivideScalar(v, dist);
            data->distance = (c.radius - s.radius - dist);
        }

        return true;
    }

    return false;
}

GLK_INLINE bool RZXCapsuleIntersectsCapsule(RZXCapsule c1, RZXCapsule c2, RZXContactData *data)
{
    RZXLineSegment a1 = RZXCapsuleGetAxis(c1);
    RZXLineSegment a2 = RZXCapsuleGetAxis(c2);

    RZXLineSegment connector = RZXLineSegmentConnect(a1, a2);

    GLKVector3 v = RZXLineSegmentGetDirection(connector);
    float dist = GLKVector3Length(v);

    if( dist <= c1.radius + c2.radius ) {
        if ( data != NULL) {
            data->normal = GLKVector3DivideScalar(v, dist);
            data->distance = (c1.radius - c2.radius - dist);
        }

        return true;
    }

    return false;
}

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
