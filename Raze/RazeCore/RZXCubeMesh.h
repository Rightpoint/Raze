//
//  RZXQuadMesh.h
//  RazeCore
//
//  Created by Rob Visentin on 4/30/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXMesh.h>

/**
 *  A procedurally generated cube mesh.
 */
@interface RZXCubeMesh : RZXMesh

/** Initialize a unit cube. The cube is size {1, 1, 1}, centered at {0, 0, 0}. */
+ (instancetype)cube;

@end

@interface RZXCubeMesh (RZXUnavailable)

// The mesh data will be procedurally generated rather then loaded from a file.
+ (instancetype)meshWithName:(NSString *)name usingCache:(BOOL)useCache UNAVAILABLE_ATTRIBUTE;

@end