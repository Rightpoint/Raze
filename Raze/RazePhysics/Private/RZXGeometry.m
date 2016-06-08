//
//  RZXGeometry.m
//  RazePhysics
//
//  Created by Rob Visentin on 6/8/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXGeometry.h>
#import <RazePhysics/RZXGJK.h>

#pragma mark - Support Mappings

// The point in the hull most distant along v is called a "supporting point"
// These are not necessarily unique
// For a polyhedron, a vertex can always be selected as a supporting point
GLK_INLINE GLKVector3 RZXHullSupport(RZXHull hull, GLKVector3 v)
{
    unsigned int idx = 0;
    float maxDot = GLKVector3DotProduct(RZXHullGetPoint(hull, 0), v);

    for ( unsigned int i = 1; i < hull.n; ++i ) {
        float dot = GLKVector3DotProduct(RZXHullGetPoint(hull, i), v);

        if ( dot > maxDot ) {
            maxDot = dot;
            idx = i;
        }
    }

    return RZXHullGetPoint(hull, idx);
}

bool RZXHullIntersectsHull(RZXHull h1, RZXHull h2)
{
    RZXGJKSupport support = ^GLKVector3 (GLKVector3 v) {
        // S(v⃗) = S1(v⃗) − S2(−v⃗)
        return GLKVector3Subtract(RZXHullSupport(h1, v), RZXHullSupport(h2, GLKVector3Negate(v)));
    };
    
    RZXGJK gjk = RZXGJKStart();

    return RZXGJKIntersection(&gjk, support);
}
