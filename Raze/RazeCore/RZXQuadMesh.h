//
//  RZXQuadMesh.h
//
//  Created by Rob Visentin on 1/10/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXBase.h>

OBJC_EXTERN NSInteger const kRZXQuadMeshMaxSubdivisions;

@interface RZXQuadMesh : NSObject <RZXRenderable>

+ (instancetype)quad;
+ (instancetype)quadWithSubdivisionLevel:(NSInteger)subdivisons;

@end
