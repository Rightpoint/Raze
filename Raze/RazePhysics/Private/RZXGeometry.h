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

typedef struct _RZXBox {
    GLKVector3 min, max;
} RZXBox;

typedef struct _RZXSphere {
    GLKVector3 center;
    float radius;
} RZXSphere;

GLK_INLINE bool RZXSphereIntersectsSphere(RZXSphere s1, RZXSphere s2)
{
    return GLKVector3Distance(s1.center, s2.center) <= (s1.radius + s2.radius);
}

GLK_INLINE bool RZXSphereIntersectsBox(RZXSphere s, RZXBox b)
{
    float r2 = s.radius * s.radius;

    // Check if the closest point of approach is within the radius of the sphere
    for ( int i = 0; i < 3; ++i ) {
        if ( s.center.v[i] < b.min.v[i] ) {
            float diff = s.center.v[i] - b.min.v[i];
            r2 -= (diff * diff);
        }
        else if ( s.center.v[i] > b.max.v[i] ) {
            float diff = s.center.v[i] - b.max.v[i];
            r2 -= (diff * diff);
        }
    }

    return (r2 >= 0.0);
}

GLK_INLINE bool RZXSphereContainsPoint(RZXSphere s, GLKVector3 p)
{
    return (GLKVector3Distance(s.center, p) < s.radius);
}

GLK_INLINE bool RZXBoxIntersectsBox(RZXBox b1, RZXBox b2)
{
    return(b1.max.x >= b2.min.x &&
           b1.min.x <= b2.max.x &&
           b1.max.y >= b2.min.y &&
           b1.min.y <= b2.max.y &&
           b1.max.z >= b2.min.z &&
           b1.min.z <= b2.max.z);
}

GLK_INLINE bool RZXBoxIntersectsSphere(RZXBox b, RZXSphere s)
{
    return RZXSphereIntersectsBox(s, b);
}

GLK_INLINE GLKVector3 RZXBoxGetCenter(RZXBox b)
{
    GLKVector3 bounds = GLKVector3Subtract(b.max, b.min);
    return GLKVector3Add(b.min, GLKVector3MultiplyScalar(bounds, 0.5f));
}

GLK_INLINE bool RZXBoxContainsPoint(RZXBox b, GLKVector3 p)
{
    return (p.x >= b.min.x && p.x <= b.max.x &&
            p.y >= b.min.y && p.y <= b.max.y &&
            p.z >= b.min.z && p.z <= b.max.z);
}

GLK_INLINE void RZXBoxTranslate(RZXBox *b, GLKVector3 trans)
{
    b->min = GLKVector3Add(b->min, trans);
    b->max = GLKVector3Add(b->max, trans);
}

GLK_INLINE void RZXBoxScale(RZXBox *b, GLKVector3 scale)
{
    GLKVector3 center = GLKVector3MultiplyScalar(GLKVector3Subtract(b->max, b->min), 0.5f);

    b->min = GLKVector3Add(center, GLKVector3Multiply(GLKVector3Subtract(b->min, center), scale));
    b->max = GLKVector3Add(center, GLKVector3Multiply(GLKVector3Subtract(b->max, center), scale));
}

GLK_INLINE void RZXBoxTransform(RZXBox *b, GLKMatrix4 t)
{
    GLKVector3 corners[8];

    GLKVector3 min = b->min;
    GLKVector3 max = b->max;

    corners[0] = RZXMatrix4TransformVector3(t, min);
    corners[1] = RZXMatrix4TransformVector3(t, GLKVector3Make(min.x, min.y, max.z));
    corners[2] = RZXMatrix4TransformVector3(t, GLKVector3Make(min.x, max.y, max.z));
    corners[3] = RZXMatrix4TransformVector3(t, GLKVector3Make(min.x, max.y, min.z));
    corners[4] = RZXMatrix4TransformVector3(t, GLKVector3Make(max.x, min.y, min.z));
    corners[5] = RZXMatrix4TransformVector3(t, GLKVector3Make(max.x, min.y, max.z));
    corners[6] = RZXMatrix4TransformVector3(t, max);
    corners[7] = RZXMatrix4TransformVector3(t, GLKVector3Make(max.x, min.y, min.z));

    for ( int i = 0; i < 8; ++i ) {
        min = GLKVector3Minimum(min, corners[i]);
        max = GLKVector3Maximum(max, corners[i]);
    }

    b->min = min;
    b->max = max;
}

GLK_INLINE GLKVector3 RZXBoxGetNearestPoint(RZXBox b, GLKVector3 p)
{
    return GLKVector3Make(
        MAX(b.min.x, MIN(p.x, b.max.x)),
        MAX(b.min.y, MIN(p.y, b.max.y)),
        MAX(b.min.z, MIN(p.z, b.max.z))
    );
}

#endif
