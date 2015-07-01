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

typedef struct _RZXBufferSet {
    GLuint vbo, ibo;
} RZXBufferSet;

@interface RZXVertexObjectData()

@property (copy, nonatomic) NSString *fileName;

@end

@implementation RZXVertexObjectData {
    GLuint _vaoIndex;
    RZXBufferSet _bufferSet;
    GLuint _indexCount;
}

+ (instancetype)vertexObjectDataWithFileName:(NSString *)fileName
{
    // TODO: caching
    return [[self alloc] initWithFileName:fileName];
}

- (instancetype)initWithFileName:(NSString *)fileName
{
    self = [super init];
    if ( self ) {
        _fileName = [fileName stringByDeletingPathExtension];
    }
    return self;
}

#pragma mark - RZXOpenGLObject

- (void)rzx_setupGL
{
    if ( _vaoIndex != 0 ) {
        // already setup
        return;
    }

    RZXGLContext *currentContext = [RZXGLContext currentContext];

    if ( currentContext != nil ) {
        NSString* filepathname = [[NSBundle mainBundle] pathForResource:self.fileName ofType:@"mesh"];
        
        if( !filepathname ) {
            NSLog(@"UNABLE TO LOCATE MODEL DATA for %@", self.fileName);
        }
        
        FILE *meshFile = fopen([filepathname cStringUsingEncoding:NSASCIIStringEncoding], "r");

        fread(&_dimensions.x, sizeof(GLfloat), 1, meshFile);
        fread(&_dimensions.y, sizeof(GLfloat), 1, meshFile);
        fread(&_dimensions.z, sizeof(GLfloat), 1, meshFile);

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

        GLuint vao, vbo, vio;
        
        glGenVertexArraysOES(1,&vao);
        [currentContext bindVertexArray:vao];

        glGenBuffers(1,&vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, uniqueVertexArraySize, uniqueVertexArray, GL_STATIC_DRAW);

        glGenBuffers(1, &vio);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vio);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort)*indexCount, indexArray, GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(kRZXVertexAttribPosition);
        glVertexAttribPointer(kRZXVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 0);
        glEnableVertexAttribArray(kRZXVertexAttribNormal);
        glVertexAttribPointer(kRZXVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 12);
        glEnableVertexAttribArray(kRZXVertexAttribTexCoord);
        glVertexAttribPointer(kRZXVertexAttribTexCoord, 2, GL_FLOAT, GL_FALSE, 32, (char*)NULL + 24);

        glBindBuffer(GL_ARRAY_BUFFER, 0);

        _vaoIndex = vao;
        _bufferSet.vbo = vbo;
        _bufferSet.ibo = vio;
        _indexCount = indexCount;
        
        free(indexArray);
        free(uniqueVertexArray);
    }
    else {
        NSLog(@"Failed to setup %@: No active context!", NSStringFromClass([self class]));
    }
}

- (void)rzx_bindGL
{
    [[RZXGLContext currentContext] bindVertexArray:_vaoIndex];
}

- (void)rzx_teardownGL
{
    if ( _vaoIndex != 0 ) {
        glDeleteVertexArraysOES(1, &_vaoIndex);
        _vaoIndex = 0;

        glDeleteBuffers(2, &_bufferSet.vbo);
        _bufferSet.vbo = 0;
        _bufferSet.ibo = 0;
    }
}

#pragma mark - RZXRenderable

- (void)rzx_render
{
    glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_SHORT, NULL);
}

@end
