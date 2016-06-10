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

#import <RazePhysics/RZXGJK.h>

typedef NS_OPTIONS(int, RZXGJKFaces) {
    RZXGJKFaceNone  = 0,
    RZXGJKFace0     = 1 << 0,
    RZXGJKFace1     = 1 << 1,
    RZXGJKFace2     = 1 << 2,
    RZXGJKFace01    = (RZXGJKFace0 | RZXGJKFace1),
    RZXGJKFace12    = (RZXGJKFace1 | RZXGJKFace2),
    RZXGJKFace20    = (RZXGJKFace2 | RZXGJKFace0)
};

#pragma mark - Utility

// Returns a vector perpendicular to A, and parallel to (in the direction of) B.
GLK_INLINE GLKVector3 RZXVector3CrossABA(GLKVector3 a, GLKVector3 b)
{
    return GLKVector3CrossProduct(GLKVector3CrossProduct(a, b), a);
}

GLK_INLINE bool RZXGJKUpdateEdge(RZXGJK *gjk, GLKVector3 edge, RZXGJKSupport s)
{
    gjk->sim[0] = s;

    // point towards origin, orthogonal to edge
    gjk->v = GLKVector3Normalize(RZXVector3CrossABA(edge, GLKVector3Negate(s.p)));

    gjk->n = 2;

    return false;
}

GLK_INLINE bool RZXGJKUpdateEdgeCCW(RZXGJK *gjk, GLKVector3 edge, RZXGJKSupport s)
{
    gjk->sim[1] = gjk->sim[0];
    gjk->sim[0] = s;

    // point towards origin, orthogonal to edge
    gjk->v = GLKVector3Normalize(RZXVector3CrossABA(edge, GLKVector3Negate(s.p)));

    gjk->n = 2;

    return false;
}

GLK_INLINE bool RZXGJKUpdateTriangle(RZXGJK *gjk, GLKVector3 normal, RZXGJKSupport s)
{
    if ( GLKVector3DotProduct(normal, s.p) < 0.0f ) {
        gjk->sim[2] = gjk->sim[0];
        gjk->sim[0] = s;

        // origin is below triangle
        gjk->v = GLKVector3Normalize(GLKVector3Negate(normal));
    }
    else {
        gjk->sim[2] = gjk->sim[1];
        gjk->sim[1] = gjk->sim[0];
        gjk->sim[0] = s;

        // origin is above triangle
        gjk->v = GLKVector3Normalize(normal);
    }
    
    gjk->n = 3;

    return false;
}

GLK_INLINE bool RZXGJKUpdateFace(RZXGJK *gjk, GLKVector3 e1, GLKVector3 e2, GLKVector3 normal, RZXGJKSupport s)
{
    // check if origin is outside the face, nearest to e1
    if ( GLKVector3DotProduct(GLKVector3CrossProduct(e1, normal), s.p) < 0.0f ) {
        return RZXGJKUpdateEdgeCCW(gjk, e1, s);
    }

    // check if origin is outside the face, nearest to e2
    if ( GLKVector3DotProduct(GLKVector3CrossProduct(normal, e2), s.p) < 0.0f ) {
        return RZXGJKUpdateEdge(gjk, e2, s);
    }

    // else, origin must be within the prism formed by extending the face along its normal

    return RZXGJKUpdateTriangle(gjk, normal, s);
}

GLK_INLINE bool RZXGJKUpdateFaceSelect(RZXGJK *gjk, GLKVector3 e1, GLKVector3 e2, GLKVector3 e3, GLKVector3 n1, GLKVector3 n2, RZXGJKSupport s)
{
    if ( GLKVector3DotProduct(GLKVector3CrossProduct(n1, e2), s.p) < 0.0f ) {
        // rotate points
        gjk->sim[0] = gjk->sim[1];
        gjk->sim[1] = gjk->sim[2];

        return RZXGJKUpdateFace(gjk, e2, e3, n2, s);
    }

    return RZXGJKUpdateTriangle(gjk, n1, s);
}

#pragma mark - Update

GLK_INLINE bool RZXGJKUpdate0(RZXGJK *gjk, RZXGJKSupport s)
{
    gjk->sim[0] = s;
    ++gjk->n;

    // point directly towards the origin next
    gjk->v = GLKVector3Normalize(GLKVector3Negate(s.p));

    return false;
}

GLK_INLINE bool RZXGJKUpdate1(RZXGJK *gjk, RZXGJKSupport s)
{
    gjk->sim[1] = gjk->sim[0];
    gjk->sim[0] = s;
    ++gjk->n;

    // next direction points towards origin and is perpendicular to the line segment
    GLKVector3 diff = GLKVector3Subtract(gjk->sim[1].p, s.p);
    gjk->v = GLKVector3Normalize(RZXVector3CrossABA(diff, GLKVector3Negate(s.p)));

    return false;
}

GLK_INLINE bool RZXGJKUpdate2(RZXGJK *gjk, RZXGJKSupport s)
{
    // edges of the triangle
    GLKVector3 e1 = GLKVector3Subtract(gjk->sim[0].p, s.p);
    GLKVector3 e2 = GLKVector3Subtract(gjk->sim[1].p, s.p);

    // normal of the triangle
    GLKVector3 normal = GLKVector3CrossProduct(e1, e2);

    return RZXGJKUpdateFace(gjk, e1, e2, normal, s);
}

GLK_INLINE bool RZXGJKUpdate3(RZXGJK *gjk, RZXGJKSupport s)
{
    // triangle edges
    GLKVector3 edges[3];

    // edge normals
    GLKVector3 normals[3];

    for ( unsigned int i = 0; i < 3; ++i ) {
        edges[i] = GLKVector3Subtract(gjk->sim[i].p, s.p);
    }

    for ( unsigned int i = 0; i < 3; ++i ) {
        normals[i] = GLKVector3CrossProduct(edges[i], edges[(i + 1) % 3]);
    }

    RZXGJKFaces aboveFaces = 0;

    // compute which edges the origin is above
    for ( unsigned int i = 0; i < 3; ++i ) {
        if ( GLKVector3DotProduct(normals[i], s.p) < 0.0f ) {
            aboveFaces |= (1 << i);
        }
    }

    switch ( aboveFaces ) {
        // origin is within the tetrahedron, report intersection
        case RZXGJKFaceNone: {
            gjk->sim[3] = s;
            gjk->n = 4;
            return true;
        }

        // origin is above only the plane formed by e0 x e1
        case RZXGJKFace0: {
            return RZXGJKUpdateFace(gjk, edges[0], edges[1], normals[0], s);
        }

        // origin is above only the plane formed by e1 x e2
        case RZXGJKFace1: {
            // rotate points
            gjk->sim[0] = gjk->sim[1];
            gjk->sim[1] = gjk->sim[2];

            return RZXGJKUpdateFace(gjk, edges[1], edges[2], normals[1], s);
        }

        // origin is above only the plane formed by e2 x e0
        case RZXGJKFace2: {
            // rotate points
            gjk->sim[1] = gjk->sim[0];
            gjk->sim[0] = gjk->sim[2];

            return RZXGJKUpdateFace(gjk, edges[2], edges[0], normals[2], s);
        }

        // origin is above both e0 x e1 and e1 x e2
        case RZXGJKFace01: {
            return RZXGJKUpdateFaceSelect(gjk, edges[0], edges[1], edges[2], normals[0], normals[1], s);
        }

        // origin is above both e1 x e2 and e2 x e0
        case RZXGJKFace12: {
            // rotate points
            RZXGJKSupport tmp = gjk->sim[0];
            gjk->sim[0] = gjk->sim[1];
            gjk->sim[1] = gjk->sim[2];
            gjk->sim[2] = tmp;

            return RZXGJKUpdateFaceSelect(gjk, edges[1], edges[2], edges[0], normals[1], normals[2], s);
        }

        // origin is above both e2 x e0 and e0 x e1
        case RZXGJKFace20: {
            // rotate points
            RZXGJKSupport tmp = gjk->sim[1];
            gjk->sim[1] = gjk->sim[0];
            gjk->sim[0] = gjk->sim[2];
            gjk->sim[2] = tmp;

            return RZXGJKUpdateFaceSelect(gjk, edges[2], edges[0], edges[1], normals[2], normals[0], s);
        }
    }

    // somehow created a degenerate simplex
    NSCAssert(false, @"RZXGJK encounted degenerate simplex.");
    return false;
}

bool RZXGJKUpdate(RZXGJK *gjk, RZXGJKSupport s)
{
    if ( GLKVector3AllEqualToVector3(s.p, RZXVector3Zero) ) {
        // if point is the origin, we're done (intersection found)
        return true;
    }

    switch ( gjk->n ) {
        case 0: return RZXGJKUpdate0(gjk, s);
        case 1: return RZXGJKUpdate1(gjk, s);
        case 2: return RZXGJKUpdate2(gjk, s);
        case 3: return RZXGJKUpdate3(gjk, s);
    }

    // something went wrong
    NSCAssert(false, @"RZXGJK encounted unexpected number of simplex points before update (%i).", gjk->n);
    return false;
}

bool RZXGJKIntersection(RZXGJK *gjk, RZXGJKSupportMapping support)
{
    for ( unsigned int i = 0; i < kRZXGJKMaxIterations; ++i ) {
        RZXGJKSupport next = support(gjk->v);

        if ( GLKVector3DotProduct(next.p, gjk->v) < 0.0f ) {
            // not approaching origin, no intersection
            return false;
        }

        if ( RZXGJKUpdate(gjk, next) ) {
            // the resulting simplex contained the origin, therefore there is an intersection
            return true;
        }
    }

    // out of iterations, report an intersection (which is probably true)
    return true;
}
