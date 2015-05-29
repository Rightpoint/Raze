//
//  RZXVertexObjectData.h
//  RazeScene
//
//  Created by John Stricker on 3/20/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXEffect.h>

@class RZXGLContext;

@interface RZXVertexObjectData : NSObject<RZXOpenGLObject>

@property (assign, nonatomic) GLuint vaoIndex;
@property (assign, nonatomic) GLuint vboIndex;
@property (assign, nonatomic) GLuint vioIndex;
@property (assign, nonatomic) GLuint vertexCount;

+ (RZXVertexObjectData *)fetchCachedObjectDataWithKey:(NSString *)keyString;
+ (void)deleteAllCachedObjects;

- (instancetype)initWithFileName:(NSString *)fileName RZXGLContext:(RZXGLContext *)context;
- (void)cacheObjectDataWithKey:(NSString *)keyString;
- (void)deleteCachedObjectData;

@end
