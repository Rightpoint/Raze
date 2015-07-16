//
//  RZXMesh.h
//  RazeCore
//
//  Created by John Stricker on 3/19/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXGPUObject.h>
#import <RazeCore/RZXRenderable.h>

OBJC_EXTERN NSString* const kRZXMeshFileExtension;

@interface RZXMesh : RZXGPUObject <RZXRenderable>

@property (nonatomic, readonly) GLKVector3 bounds;

+ (instancetype)meshWithName:(NSString *)name usingCache:(BOOL)useCache;

@end
