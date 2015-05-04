//
//  RZXMesh.m
//  RazeScene
//
//  Created by John Stricker on 3/19/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXMesh.h"

#import <OpenGLES/ES2/glext.h>
#import <RazeScene/RZXVertexObjectData.h>
#import <RazeCore/RZXGLContext.h>

@interface RZXMesh()

@property (copy, nonatomic)NSString *meshName;
@property (copy, nonatomic)NSString *meshFileName;

@property (strong, nonatomic)RZXVertexObjectData *vertexObjectData;

@end

@implementation RZXMesh

+ (instancetype)meshWithName:(NSString *)name meshFileName:(NSString *)meshFileName
{
    return [[self alloc] initWithName:name meshFileName:meshFileName];
}

#pragma mark - RZOpenGLObject

- (void)setupGL
{
    RZXGLContext *currentContext = [RZXGLContext currentContext];
    if ( currentContext != nil ) {
        NSString *cacheKey = [self rzx_cacheKeyForContext:currentContext];
        RZXVertexObjectData *vod = [RZXVertexObjectData fetchCachedObjectDataWithKey:cacheKey];
        if ( vod == nil ) {
            vod = [[RZXVertexObjectData alloc] initWithFileName:_meshFileName RZXGLContext:currentContext];
            [vod setupGL];
            [vod cacheObjectDataWithKey:cacheKey];
        }
        else {
            self.vertexObjectData = vod;
        }
    }
}

- (void)bindGL
{
    [self.vertexObjectData bindGL];
}

- (void)teardownGL
{
    [self.vertexObjectData teardownGL];
}

#pragma mark - RZRenderable

- (void)render
{
    glDrawElements(GL_TRIANGLES, self.vertexObjectData.vertexCount, GL_UNSIGNED_INT, NULL);
}

#pragma mark - private methods

- (instancetype)initWithName:(NSString *)name meshFileName:(NSString *)meshFileName
{
    self = [super init];
    if ( self != nil ) {
        _meshName = name;
        _meshFileName = meshFileName;
    }
    return self;
}

- (NSString *)rzx_cacheKeyForContext:(RZXGLContext *)context
{
    return [NSString stringWithFormat:@"%@%p",self.meshName,context];
}



@end
