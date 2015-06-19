//
//  RZXVertexObjectData.m
//  RazeScene
//
//  Created by John Stricker on 3/20/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>
#import <RazeCore/RZXGLContext.h>

#import "RZXVertexObjectData.h"

@interface RZXVertexObjectData()

@property (copy, nonatomic) NSString *cacheKey;
@property (copy, nonatomic, readonly) NSString *fileName;
@property (strong, nonatomic) RZXGLContext *context;

@end

@implementation RZXVertexObjectData {
    GLuint _vaoIndex;
    GLuint _vboIndex;
    GLuint _vioIndex;
    GLuint _indexCount;
}

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
        glDeleteVertexArraysOES(1, &_vaoIndex);
        glDeleteBuffers(1, &_vboIndex);
        glDeleteBuffers(1, &_vioIndex);
        
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
    if ( _vaoIndex != 0 ) {
        // already setup
        return;
    }

    NSString* filepathname = [[NSBundle mainBundle] pathForResource:self.fileName ofType:@"mesh"];
    
    if(!filepathname)
    {
        NSLog(@"UNABLE TO LOCATE MODEL DATA for %@",self.fileName);
    }
    
    FILE *meshFile = fopen([filepathname cStringUsingEncoding:NSASCIIStringEncoding], "r");
    
    GLint indexCount;
    fread(&indexCount, sizeof(GLint), 1, meshFile);
    
    GLushort *indexArray = (GLushort *)malloc(indexCount * sizeof(GLushort));
    fread(indexArray, 1, indexCount*sizeof(GLushort), meshFile);
    
    GLint uniqueVertexCount;
    fread(&uniqueVertexCount, sizeof(GLint), 1, meshFile);
    
    GLint uniqueVertexArraySize = uniqueVertexCount * 8 * sizeof(GLfloat);
    GLfloat *uniqueVertexArray = (GLfloat *)malloc(uniqueVertexArraySize);
    fread(uniqueVertexArray, 1, uniqueVertexArraySize, meshFile);
    
    fclose(meshFile);
    
    int arraySize = uniqueVertexCount * 8 * sizeof(GLfloat);
    
    GLuint vao, vbo, vio;
    
    glGenVertexArraysOES(1,&vao);
    glBindVertexArrayOES(vao);
    
    glGenBuffers(1, &vio);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vio);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort)*indexCount, indexArray, GL_STATIC_DRAW);
    
    glGenBuffers(1,&vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, arraySize, uniqueVertexArray, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 12);
    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 24);

    glBindBuffer(GL_ARRAY_BUFFER, 0);

    _vaoIndex = vao;
    _vboIndex = vbo;
    _vioIndex = vio;
    _indexCount = indexCount;
    
    //used for testing model output
    
    printf("indexes:\n");
    for (int i = 0; i < indexCount; ++i) {
        printf("%d ", indexArray[i]);
    }
    
    int colCount = 0;
    printf("\nVert data \n");
    for(int i = 0; i < uniqueVertexCount; ++i)
    {
        printf("%f",uniqueVertexArray[i]);
        if(++colCount == 8)
        {
            printf("\n");
            colCount = 0;
        }
        else
        {
            printf(", ");
        }
    }

    
    free(indexArray);
    free(uniqueVertexArray);
}

- (void)bindGL
{
    [[RZXGLContext currentContext] bindVertexArray:_vaoIndex];
}

- (void)teardownGL
{
    [self deleteCachedObjectData];
}

#pragma mark - RZXRenderable

- (void)render
{
    glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_SHORT, NULL);
}

@end
