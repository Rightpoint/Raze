//
//  RZXGJK.h
//  RazePhysics
//
//  Created by Rob Visentin on 6/8/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//
// Implementation of the Gilbert–Johnson–Keerthi distance algorithm
// Adapted from http://vec3.ca/gjk/implementation/
// See Also: http://realtimecollisiondetection.net/pubs/SIGGRAPH04_Ericson_GJK_notes.pdf

#ifndef RZXGJK_h
#define RZXGJK_h

#include <RazePhysics/RZXGeometry.h>

// Cap the number of iterations to avoid rare ping-ponging due to floating point precision issues
static unsigned int kRZXGJKMaxIterations = 32;

// Return the supporting point for normalized direction v.
typedef GLKVector3 (^RZXGJKSupport)(GLKVector3 v);

typedef struct _RZXGJK
{
    GLKVector3 v;       // current search direction (normalized)
    GLKVector3 sim[3];  // points in the simplex, ordered such that the origin is above the simplex
    unsigned int n;     // number of points in the current simplex
} RZXGJK;

GLK_INLINE RZXGJK RZXGJKStart()
{
    return (RZXGJK) {
        .v = GLKVector3Make(1.0f, 0.0f, 0.0f), // arbitrary starting vector
        .n = 0
    };
}

GLK_EXTERN bool RZXGJKUpdate(RZXGJK *gjk, GLKVector3 p);

GLK_EXTERN bool RZXGJKIntersection(RZXGJK *gjk, RZXGJKSupport support);

#endif
