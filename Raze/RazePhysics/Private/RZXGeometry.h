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

typedef struct _RZXSphere {
    GLKVector3 center;
    float radius;
} RZXSphere;

typedef struct _RZXBox {
    GLKVector3 center;
    GLKVector3 radius;
    GLKVector3 axes[3]; // orthonormal vectors storing the xyz axes transformed to local space
} RZXBox;

typedef struct _RZXLineSegment
{
    GLKVector3 p1, p2;
} RZXLineSegment;

typedef struct _RZXLine
{
    GLKVector3 p0, v;  // line of form p0 + vt
} RZXLine;

#pragma mark - Spheres

GLK_INLINE bool RZXSphereContainsPoint(RZXSphere s, GLKVector3 p)
{
    return (GLKVector3Distance(s.center, p) < s.radius);
}


GLK_INLINE bool RZXSphereIntersectsSphere(RZXSphere s1, RZXSphere s2)
{
    return GLKVector3Distance(s1.center, s2.center) <= (s1.radius + s2.radius);
}

#pragma mark - Boxes

GLK_INLINE GLKVector3 RZXBoxGetSize(RZXBox b)
{
    return GLKVector3MultiplyScalar(b.radius, 2.0f);
}

GLK_INLINE GLKQuaternion RZXBoxGetRotation(RZXBox b)
{
    GLKMatrix3 mat;

    for ( int c = 0; c < 3; ++c ) {
        for ( int r = 0; r < 3; ++r ) {
            mat.m[3 * c + r] = GLKVector3DotProduct(b.axes[c], b.axes[r]);
        }
    }

    return GLKQuaternionMakeWithMatrix3(mat);
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

GLK_INLINE bool RZXBoxContainsPoint(RZXBox b, GLKVector3 p)
{
    GLKVector3 diff = GLKVector3Subtract(p, b.center);

    for ( int i = 0; i < 3; ++i ) {
        if ( abs(GLKVector3DotProduct(diff, b.axes[i])) > b.radius.v[i] ) {
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

#endif
