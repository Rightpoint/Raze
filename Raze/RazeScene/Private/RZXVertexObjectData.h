//
//  RZXVertexObjectData.h
//  RazeScene
//
//  Created by John Stricker on 3/20/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXRenderable.h>
#import <GLKit/GLKMathTypes.h>

@interface RZXVertexObjectData : NSObject <RZXRenderable>

@property (assign, readonly) GLKVector3 dimensions;

+ (RZXVertexObjectData *)vertexObjectDataWithFileName:(NSString *)fileName;
+ (void)deleteAllCachedObjects;

- (void)deleteCachedObjectData;

@end
