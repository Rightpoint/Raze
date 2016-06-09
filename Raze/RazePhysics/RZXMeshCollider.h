//
//  RZXMeshCollider.h
//  RazePhysics
//
//  Created by Rob Visentin on 6/8/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCollider.h>

@class RZXMesh;

@interface RZXMeshCollider : RZXCollider

/**
 *  Returns a new collider with the given mesh.
 *
 *  @param mesh The mesh to use as a collision hull. Must be convex.
 *
 *  @note The mesh MUST be convex.
 *  @todo Implement convex hull generation for non-convex meshes.
 */
+ (instancetype)colliderWithConvexMesh:(RZXMesh *)mesh;

/**
 *  Returns a new collider with the given mesh.
 *
 *  @param mesh The mesh to use as a collision hull. Must be convex.
 *
 *  @note The mesh MUST be convex.
 *  @todo Implement convex hull generation for non-convex meshes.
 */
- (instancetype)initWithConvexMesh:(RZXMesh *)mesh;

@end
