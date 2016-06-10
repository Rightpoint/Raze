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

typedef struct _RZXGJKSupport {
    GLKVector3 p;   // support point of the Minkowski difference

    GLKVector3 s;   // support point of the first polytope
                    // NOTE: the support point of the second polytope can be derived from p and s if needed
} RZXGJKSupport;

typedef struct _RZXGJK {
    GLKVector3 v;           // current search direction (normalized)
    RZXGJKSupport sim[4];   // points in the simplex, ordered such that the origin is above the simplex
    unsigned int n;         // number of points in the current simplex
} RZXGJK;

// Return the supporting point for normalized direction v.
typedef RZXGJKSupport (^RZXGJKSupportMapping)(GLKVector3 v);

GLK_INLINE RZXGJK RZXGJKStart(void)
{
    return (RZXGJK) {
        .v = GLKVector3Make(1.0f, 0.0f, 0.0f), // arbitrary starting vector
        .n = 0
    };
}

GLK_EXTERN void RZXGJKUpdate(RZXGJK *gjk, RZXGJKSupport s);

// Returns whether an intersection was found.
// If `true`, then gjk->sim will contain the simplex enclosing the origin.
GLK_EXTERN bool RZXGJKIntersection(RZXGJK *gjk, RZXGJKSupportMapping support);

// Returns the contact normal of the intersection using the EPA algorithm.
// gjk should contain a tetrahedron simplex (gjk->n = 4)
GLK_EXTERN bool RZXGJKGetContactData(const RZXGJK *gjk, RZXGJKSupportMapping support, RZXContactData *data);

#endif
