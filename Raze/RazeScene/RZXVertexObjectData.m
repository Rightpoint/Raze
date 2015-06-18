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
#import <RazeCore/RZXGLContext.h>

@interface RZXVertexObjectData()

@property (copy, nonatomic) NSString *cacheKey;
@property (copy, nonatomic, readonly) NSString *fileName;
@property (strong, nonatomic) RZXGLContext *context;


@end

@implementation RZXVertexObjectData

+ (RZXVertexObjectData *)fetchCachedObjectDataWithKey:(NSString *)keyString
{
    NSMutableDictionary *cache = [RZXVertexObjectData cachedVertexObjects];
    return cache[keyString];
}

+ (void)deleteAllCachedObjects
{
    NSMutableDictionary *cache = [RZXVertexObjectData cachedVertexObjects];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    for ( NSString *key in cache ) {
        [keys addObject:key];
    }
    
    for ( NSString *key in keys ) {
        RZXVertexObjectData *vod = cache[key];
        [vod deleteCachedObjectData];
    }
    
    [cache removeAllObjects];
}

+ (NSMutableDictionary *)cachedVertexObjects
{
    static NSMutableDictionary *cacheDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheDictionary = [[NSMutableDictionary alloc] init];
    });
    return cacheDictionary;
}

- (instancetype)initWithFileName:(NSString *)fileName RZXGLContext:(RZXGLContext *)context
{
    self = [super init];
    if ( self ) {
        _fileName = [fileName stringByDeletingPathExtension];
        _context = context;
    }
    return self;
}

- (void)deleteCachedObjectData
{
    RZXVertexObjectData *cachedData = [RZXVertexObjectData cachedVertexObjects][self.cacheKey];
    
    if ( cachedData != nil ) {
        GLuint vao = self.vaoIndex;
        GLuint vbo = self.vboIndex;
        GLuint vio = self.vioIndex;
        glDeleteVertexArraysOES(1, &vao);
        glDeleteBuffers(1, &vbo);
        glDeleteBuffers(1, &vio);
        
        [[RZXVertexObjectData cachedVertexObjects] removeObjectForKey:self.cacheKey];
    }
}

- (void)cacheObjectDataWithKey:(NSString *)keyString
{
    self.cacheKey = keyString;
    [RZXVertexObjectData cachedVertexObjects][keyString] = self;
}

#pragma mark - RZOpenGLObject

- (void)setupGL
{
    NSString* filepathname = [[NSBundle mainBundle] pathForResource:self.fileName ofType:@"mesh"];
    
    if(!filepathname)
    {
        NSLog(@"UNABLE TO LOCATE MODEL DATA for %@",self.fileName);
    }
    
    FILE *meshFile = fopen([filepathname cStringUsingEncoding:NSASCIIStringEncoding], "r");
    
    GLushort indexCount;
    fread(&indexCount, sizeof(GLushort), 1, meshFile);
    
    GLushort *indexArray = (GLushort*)malloc(indexCount * sizeof(GLushort));
    fread(indexArray, sizeof(GLushort), indexCount, meshFile);
    
    GLushort uniqueVertexCount;
    fread(&uniqueVertexCount, sizeof(GLushort), 1, meshFile);
    
    int uniqueVertexArraySize = (int)uniqueVertexCount * 8 * sizeof(GLfloat);
    GLfloat *uniqueVertexArray = (GLfloat*)malloc(uniqueVertexArraySize);
    fread(uniqueVertexArray, 1, uniqueVertexArraySize, meshFile);
    
    fclose(meshFile);
    
    GLuint vao, vbo, vio;
    
    glGenVertexArraysOES(1,&vao);
    glBindVertexArrayOES(vao);
    
    glGenBuffers(1, &vio);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vio);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort)*indexCount, indexArray, GL_STATIC_DRAW);
    
    glGenBuffers(1,&vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, uniqueVertexArraySize,uniqueVertexArray, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(kRZXVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(kRZXVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 12);
    glEnableVertexAttribArray(2);
    glVertexAttribPointer(kRZXVertexAttribTexCoord, 2, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 24);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    RZXVertexObjectData *obd = [[RZXVertexObjectData alloc] init];
    obd.vaoIndex = vao;
    obd.vboIndex = vbo;
    obd.vioIndex = vio;
    obd.vertexCount = indexCount;
    
    free(indexArray);
    free(uniqueVertexArray);
}

- (void)bindGL
{
    [[RZXGLContext currentContext] bindVertexArray:self.vaoIndex];
}

- (void)teardownGL
{
    [self deleteCachedObjectData];
}


@end
