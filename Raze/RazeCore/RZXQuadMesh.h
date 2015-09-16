//
//  RZXQuadMesh.h
//  RazeCore
//
//  Created by Rob Visentin on 1/10/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXMesh.h>

OBJC_EXTERN NSInteger const kRZXQuadMeshMaxSubdivisions;

/**
 *  A procedurally generated rectangular mesh.
 */
@interface RZXQuadMesh : RZXMesh

/** Initialize a basic quad. */
+ (instancetype)quad;

/** Initialize a quad with a specific number of subdivisions. */
+ (instancetype)quadWithSubdivisionLevel:(NSInteger)subdivisons;

@end

@interface RZXQuadMesh (RZXUnavailable)

// The mesh data will be procedurally generated rather then loaded from a file.
+ (instancetype)meshWithName:(NSString *)name usingCache:(BOOL)useCache UNAVAILABLE_ATTRIBUTE;

@end
