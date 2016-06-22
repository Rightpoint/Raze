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
#import <list>

// Cap the number of iterations to avoid rare ping-ponging scenarios
static const unsigned int kRZXGJKMaxIterations = 64;
static const float kRZXGJKTerminationThreshold = 1e-3f;

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

GLK_INLINE void RZXGJKUpdateEdge(RZXGJK *gjk, GLKVector3 edge, RZXGJKSupport s)
{
    gjk->sim[0] = s;

    // point towards origin, orthogonal to edge
    gjk->v = GLKVector3Normalize(RZXVector3CrossABA(edge, GLKVector3Negate(s.p)));

    gjk->n = 2;
}

GLK_INLINE void RZXGJKUpdateEdgeCCW(RZXGJK *gjk, GLKVector3 edge, RZXGJKSupport s)
{
    gjk->sim[1] = gjk->sim[0];
    gjk->sim[0] = s;

    // point towards origin, orthogonal to edge
    gjk->v = GLKVector3Normalize(RZXVector3CrossABA(edge, GLKVector3Negate(s.p)));

    gjk->n = 2;
}

GLK_INLINE void RZXGJKUpdateTriangle(RZXGJK *gjk, GLKVector3 normal, RZXGJKSupport s)
{
    if ( GLKVector3DotProduct(normal, s.p) < 0.0f ) {
        gjk->sim[2] = gjk->sim[1];
        gjk->sim[1] = gjk->sim[0];
        gjk->sim[0] = s;

        // origin is above triangle
        gjk->v = GLKVector3Normalize(normal);
    }
    else {
        gjk->sim[2] = gjk->sim[0];
        gjk->sim[0] = s;

        // origin is below triangle
        gjk->v = GLKVector3Normalize(GLKVector3Negate(normal));
    }
    
    gjk->n = 3;
}

GLK_INLINE void RZXGJKUpdateFace(RZXGJK *gjk, GLKVector3 e1, GLKVector3 e2, GLKVector3 normal, RZXGJKSupport s)
{
    // check if origin is outside the face, nearest to e1
    if ( GLKVector3DotProduct(GLKVector3CrossProduct(e1, normal), s.p) < 0.0f ) {
        RZXGJKUpdateEdgeCCW(gjk, e1, s);
    }

    // check if origin is outside the face, nearest to e2
    else if ( GLKVector3DotProduct(GLKVector3CrossProduct(normal, e2), s.p) < 0.0f ) {
        RZXGJKUpdateEdge(gjk, e2, s);
    }

    // origin must be within the prism formed by extending the face along its normal
    else {
        RZXGJKUpdateTriangle(gjk, normal, s);
    }
}

GLK_INLINE void RZXGJKUpdateFaceSelect(RZXGJK *gjk, GLKVector3 e1, GLKVector3 e2, GLKVector3 e3, GLKVector3 n1, GLKVector3 n2, RZXGJKSupport s)
{
    if ( GLKVector3DotProduct(GLKVector3CrossProduct(n1, e2), s.p) < 0.0f ) {
        // rotate points
        gjk->sim[0] = gjk->sim[1];
        gjk->sim[1] = gjk->sim[2];

        RZXGJKUpdateFace(gjk, e2, e3, n2, s);
    }
    else {
        RZXGJKUpdateTriangle(gjk, n1, s);

    }
}

#pragma mark - Update

GLK_INLINE void RZXGJKUpdate0(RZXGJK *gjk, RZXGJKSupport s)
{
    gjk->sim[0] = s;
    gjk->n = 1;

    // point directly towards the origin next
    gjk->v = GLKVector3Normalize(GLKVector3Negate(s.p));
}

GLK_INLINE void RZXGJKUpdate1(RZXGJK *gjk, RZXGJKSupport s)
{
    GLKVector3 edge = GLKVector3Subtract(gjk->sim[0].p, s.p);
    RZXGJKUpdateEdgeCCW(gjk, edge, s);
}

GLK_INLINE void RZXGJKUpdate2(RZXGJK *gjk, RZXGJKSupport s)
{
    // edges of the triangle
    GLKVector3 e1 = GLKVector3Subtract(gjk->sim[0].p, s.p);
    GLKVector3 e2 = GLKVector3Subtract(gjk->sim[1].p, s.p);

    // normal of the triangle
    GLKVector3 normal = GLKVector3CrossProduct(e1, e2);

    RZXGJKUpdateFace(gjk, e1, e2, normal, s);
}

GLK_INLINE void RZXGJKUpdate3(RZXGJK *gjk, RZXGJKSupport s)
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
        // origin is within the tetrahedron (intersection)
        // construct the final simplex
        case RZXGJKFaceNone: {
            gjk->sim[3] = s;
            gjk->n = 4;
            break;
        }

        // origin is above only the plane formed by e0 x e1
        case RZXGJKFace0: {
            RZXGJKUpdateFace(gjk, edges[0], edges[1], normals[0], s);
            break;
        }

        // origin is above only the plane formed by e1 x e2
        case RZXGJKFace1: {
            // rotate points
            gjk->sim[0] = gjk->sim[1];
            gjk->sim[1] = gjk->sim[2];

            RZXGJKUpdateFace(gjk, edges[1], edges[2], normals[1], s);
            break;
        }

        // origin is above only the plane formed by e2 x e0
        case RZXGJKFace2: {
            // rotate points
            gjk->sim[1] = gjk->sim[0];
            gjk->sim[0] = gjk->sim[2];

            RZXGJKUpdateFace(gjk, edges[2], edges[0], normals[2], s);
            break;
        }

        // origin is above both e0 x e1 and e1 x e2
        case RZXGJKFace01: {
            RZXGJKUpdateFaceSelect(gjk, edges[0], edges[1], edges[2], normals[0], normals[1], s);
            break;
        }

        // origin is above both e1 x e2 and e2 x e0
        case RZXGJKFace12: {
            // rotate points
            RZXGJKSupport tmp = gjk->sim[0];
            gjk->sim[0] = gjk->sim[1];
            gjk->sim[1] = gjk->sim[2];
            gjk->sim[2] = tmp;

            RZXGJKUpdateFaceSelect(gjk, edges[1], edges[2], edges[0], normals[1], normals[2], s);
            break;
        }

        // origin is above both e2 x e0 and e0 x e1
        case RZXGJKFace20: {
            // rotate points
            RZXGJKSupport tmp = gjk->sim[1];
            gjk->sim[1] = gjk->sim[0];
            gjk->sim[0] = gjk->sim[2];
            gjk->sim[2] = tmp;

            RZXGJKUpdateFaceSelect(gjk, edges[2], edges[0], edges[1], normals[2], normals[0], s);
            break;
        }

        // somehow created a degenerate simplex
        default:
            NSCAssert(false, @"RZXGJK encounted degenerate simplex.");
    }
}

void RZXGJKUpdate(RZXGJK *gjk, RZXGJKSupport s)
{
    switch ( gjk->n ) {
        case 0: RZXGJKUpdate0(gjk, s); break;
        case 1: RZXGJKUpdate1(gjk, s); break;
        case 2: RZXGJKUpdate2(gjk, s); break;
        case 3: RZXGJKUpdate3(gjk, s); break;

        // something went wrong
        default: {
            NSCAssert(false, @"RZXGJK encounted unexpected number of simplex points before update (%i).", gjk->n);
        }
    }
}

bool RZXGJKIntersection(RZXGJK *gjk, RZXGJKSupportMapping support)
{
    for ( unsigned int i = 0; i < kRZXGJKMaxIterations; ++i ) {
        RZXGJKSupport next = support(gjk->v);

        if ( GLKVector3DotProduct(next.p, gjk->v) < kRZXGJKTerminationThreshold ) {
            // not approaching origin, no intersection
            return false;
        }

        RZXGJKUpdate(gjk, next);

        if ( gjk->n == 4 ) {
            // the resulting simplex contains the origin
            return true;
        }
    }

    // out of iterations (extremely rare case, often due to poor support mappings)
    return false;
}

#pragma mark - EPA

typedef struct _RZXEPATriangle {
    RZXGJKSupport points[3];
    GLKVector3 normal;
} RZXEPATriangle;

typedef struct _RZXEPAEdge {
    RZXGJKSupport p0, p1;
} RZXEPAEdge;

GLK_INLINE RZXEPATriangle RZXEPATriangleMake(RZXGJKSupport a, RZXGJKSupport b, RZXGJKSupport c)
{
    RZXEPATriangle t;
    t.points[0] = a;
    t.points[1] = b;
    t.points[2] = c;

    t.normal = GLKVector3CrossProduct(GLKVector3Subtract(b.p, a.p), GLKVector3Subtract(c.p, a.p));
    t.normal = GLKVector3Normalize(t.normal);

    return t;
}

GLK_INLINE float RZXEPATriangleGetDistanceFromOrigin(const RZXEPATriangle &t)
{
    return fabsf(GLKVector3DotProduct(t.normal, t.points[0].p));
}

GLK_INLINE bool RZXEPATriangleVisibleFromPoint(const RZXEPATriangle &t, GLKVector3 p)
{
    GLKVector3 diff = GLKVector3Subtract(p, t.points[0].p);
    return (GLKVector3DotProduct(t.normal, diff) > 0.0f);
}

GLK_INLINE void RZXEPAEdgeListInsertTriangle(std::list<RZXEPAEdge> &list, const RZXEPATriangle &t)
{
    RZXEPAEdge edges[3];

    edges[0] = (RZXEPAEdge){ .p0 = t.points[0], .p1 = t.points[1] };
    edges[1] = (RZXEPAEdge){ .p0 = t.points[1], .p1 = t.points[2] };
    edges[2] = (RZXEPAEdge){ .p0 = t.points[2], .p1 = t.points[0] };

    for ( unsigned int i = 0; i < 3; ++i ) {
        bool addEdge = true;

        for ( auto it = list.begin(); addEdge && it != list.end(); ++it ) {
            // if an opposite edge is found, remove it and don't insert the new one
            if ( GLKVector3AllEqualToVector3(edges[i].p0.p, it->p1.p) && GLKVector3AllEqualToVector3(edges[i].p1.p, it->p0.p) ) {
                list.erase(it);
                addEdge = false;
            }
        }

        if ( addEdge ) {
            list.emplace_back(edges[i]);
        }
    }
}

// EPA as described by http://allenchou.net/2013/12/game-physics-contact-generation-epa/
// Adapted from http://hacktank.net/blog/?p=119
bool RZXGJKGetContactData(const RZXGJK *gjk, RZXGJKSupportMapping support, RZXContactData *data)
{
    NSCAssert(gjk->n == 4, @"RZXGJK requires a tetrahedron to compute contact normals.");

    std::list<RZXEPATriangle> triangles;
    std::list<RZXEPAEdge> edges;

    triangles.emplace_back(RZXEPATriangleMake(gjk->sim[0], gjk->sim[1], gjk->sim[2]));
    triangles.emplace_back(RZXEPATriangleMake(gjk->sim[0], gjk->sim[2], gjk->sim[3]));
    triangles.emplace_back(RZXEPATriangleMake(gjk->sim[0], gjk->sim[3], gjk->sim[1]));
    triangles.emplace_back(RZXEPATriangleMake(gjk->sim[1], gjk->sim[3], gjk->sim[2]));

    for ( unsigned int i = 0; i < kRZXGJKMaxIterations && triangles.size() > 0; ++i ) {
        RZXEPATriangle nearestTriangle = *triangles.begin();
        float nearestDist = RZXEPATriangleGetDistanceFromOrigin(nearestTriangle);

        // find the triangle nearest to the origin
        for ( auto it = ++triangles.begin(); it != triangles.end(); ++it ) {
            float dist = RZXEPATriangleGetDistanceFromOrigin(*it);

            if ( dist < nearestDist ) {
                nearestDist = dist;
                nearestTriangle = *it;
            }
        }

        // compute the support point along triangle's normal
        RZXGJKSupport next = support(nearestTriangle.normal);

        // if the next point doesn't move farther from the origin, we've found the closest triangle
        if ( GLKVector3DotProduct(nearestTriangle.normal, next.p) - nearestDist < kRZXGJKTerminationThreshold ) {
            if ( data != NULL ) {
                data->normal = GLKVector3Negate(nearestTriangle.normal);
                data->distance = RZXEPATriangleGetDistanceFromOrigin(nearestTriangle);
            }
            return true;
        }

        // remove triangles visible from the support point
        for ( auto it = triangles.begin(); it != triangles.end(); ++it) {
            if ( RZXEPATriangleVisibleFromPoint(*it, next.p) ) {
                RZXEPAEdgeListInsertTriangle(edges, *it);

                it = triangles.erase(it);
                --it;
            }
        }

        // create new triangles from the edges of the removed triangles
        for(auto it = edges.begin(); it != edges.end(); it++) {
            triangles.emplace_back(RZXEPATriangleMake(next ,it->p0, it->p1));
        }

        edges.clear();
    }

    // either ran out of iterations (a rare case probably caused by numerical instability),
    // or something went wrong and there were no triangles left
    return false;
}
