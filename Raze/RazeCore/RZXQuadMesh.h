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
 *  A procedurally generated square mesh
 */
@interface RZXQuadMesh : RZXMesh

/**
 *  Initilize a basic quad
 *
 *  @return a quad with 4 points
 */
+ (instancetype)quad;

/**
 *  Initialize a quad with a specific number of subdivisions
 *
 *  @param subdivisons number of subdivisions
 *
 *  @return a subdivided qaud
 */
+ (instancetype)quadWithSubdivisionLevel:(NSInteger)subdivisons;

@end

@interface RZXQuadMesh (RZXUnavailable)

+ (instancetype)meshWithName:(NSString *)name usingCache:(BOOL)useCache UNAVAILABLE_ATTRIBUTE;

@end
