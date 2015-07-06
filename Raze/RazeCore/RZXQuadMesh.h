//
//  RZXQuadMesh.h
//  RazeCore
//
//  Created by Rob Visentin on 1/10/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXMesh.h>

OBJC_EXTERN NSInteger const kRZXQuadMeshMaxSubdivisions;

@interface RZXQuadMesh : RZXMesh <RZXRenderable>

+ (instancetype)quad;
+ (instancetype)quadWithSubdivisionLevel:(NSInteger)subdivisons;

@end

@interface RZXQuadMesh (RZXUnavailable)

+ (instancetype)meshWithName:(NSString *)name meshFileName:(NSString *)meshFileName UNAVAILABLE_ATTRIBUTE;

@end
