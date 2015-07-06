//
//  RZXMesh.h
//  RazeCore
//
//  Created by John Stricker on 3/19/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <GLKit/GLKMathTypes.h>
#import <RazeCore/RZXRenderable.h>

@interface RZXMesh : NSObject <RZXRenderable>

@property (nonatomic, readonly) GLKVector3 bounds;

+ (instancetype)meshWithName:(NSString *)name meshFileName:(NSString *)meshFileName;

@end
