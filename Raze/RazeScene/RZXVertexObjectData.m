//
//  RZXVertexObjectData.m
//  RazeScene
//
//  Created by John Stricker on 3/20/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXVertexObjectData.h"
#import <OpenGLES/ES2/glext.h>
#import <RazeCore/RZXEffect.h>

static NSMutableDictionary *cachedVertexObjectIdentifiers;

@interface RZXVertexObjectData()

@property (copy, nonatomic) NSString *cacheKey;

@end

@implementation RZXVertexObjectData

+ (RZXVertexObjectData *)fetchCachedObjectDataWithKey:(NSString *)keyString
{
    return cachedVertexObjectIdentifiers[keyString];
}

+ (void)deleteAllCachedObjects
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    for ( NSString *key in cachedVertexObjectIdentifiers ) {
        [keys addObject:key];
    }
    
    for ( NSString *key in keys ) {
        RZXVertexObjectData *vod = cachedVertexObjectIdentifiers[key];
        [vod deleteCachedObjectData];
    }
}

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        if ( cachedVertexObjectIdentifiers == nil ) {
            cachedVertexObjectIdentifiers = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)deleteCachedObjectData
{
    if ( self.vaoIndex != 0 ) {
        GLuint vao = self.vaoIndex;
        GLuint vbo = self.vboIndex;
        GLuint vio = self.vioIndex;
        glDeleteVertexArraysOES(1, &vao);
        glDeleteBuffers(1, &vbo);
        glDeleteBuffers(1, &vio);
        
        [cachedVertexObjectIdentifiers removeObjectForKey:self.cacheKey];
    }
}

- (void)cacheObjectDataWithKey:(NSString *)keyString
{
    self.cacheKey = keyString;
    cachedVertexObjectIdentifiers[keyString] = self;
}

@end
