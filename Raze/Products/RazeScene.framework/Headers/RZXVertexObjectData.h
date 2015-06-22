//
//  RZXVertexObjectData.h
//  RazeScene
//
//  Created by John Stricker on 3/20/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXRenderable.h>

@class RZXGLContext;

@interface RZXVertexObjectData : NSObject <RZXRenderable>

+ (RZXVertexObjectData *)fetchCachedObjectDataWithKey:(NSString *)keyString;
+ (void)deleteAllCachedObjects;

- (instancetype)initWithFileName:(NSString *)fileName RZXGLContext:(RZXGLContext *)context;
- (void)cacheObjectDataWithKey:(NSString *)keyString;
- (void)deleteCachedObjectData;

@end
