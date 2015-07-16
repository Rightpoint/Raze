//
//  RZXMesh.m
//  RazeCore
//
//  Created by John Stricker on 3/19/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXMesh.h>

typedef struct _RZXBufferSet {
    GLuint vbo, ibo;
} RZXBufferSet;

NSString* const kRZXMeshFileExtension = @"mesh";

@interface RZXMesh()

@property (copy, nonatomic) NSString *meshName;
@property (assign, nonatomic) BOOL usingCache;

@end

@implementation RZXMesh {
    GLuint _vao;
    RZXBufferSet _bufferSet;
    GLuint _indexCount;
}

+ (instancetype)meshWithName:(NSString *)name usingCache:(BOOL)useCache
{
    return [[self alloc] initWithName:name usingCache:useCache];
}

#pragma mark - RZXGPUObject overrides

- (RZXGPUObjectTeardownBlock)teardownHandler
{
    RZXGPUObjectTeardownBlock teardown = nil;

    if ( _vao != 0 ) {
        GLuint vao = _vao;
        RZXBufferSet bufferSet = _bufferSet;
        teardown = ^(RZXGLContext *context) {
            glDeleteVertexArrays(1, &vao);
            glDeleteBuffers(2, &bufferSet.vbo);
        };
    }

    return teardown;
}

- (BOOL)setupGL
{
    BOOL setup = [super setupGL];

    if ( setup ) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:self.meshName ofType:kRZXMeshFileExtension];

        if( filePath.length == 0 ) {
            NSLog(@"Failed to load mesh data from file named %@. Reason: unable to locate %@", self.meshName, [self.meshName stringByAppendingPathExtension:kRZXMeshFileExtension]);
            setup = NO;
        }
        else {
            FILE *meshFile = fopen([filePath cStringUsingEncoding:NSASCIIStringEncoding], "r");

            fread(&_bounds.x, sizeof(GLfloat), 1, meshFile);
            fread(&_bounds.y, sizeof(GLfloat), 1, meshFile);
            fread(&_bounds.z, sizeof(GLfloat), 1, meshFile);

            fread(&_indexCount, sizeof(GLuint), 1, meshFile);

            GLushort *indexArray = (GLushort *)malloc(_indexCount * sizeof(GLushort));
            fread(indexArray, 1, _indexCount*sizeof(GLushort), meshFile);

            GLuint uniqueVertexCount;
            fread(&uniqueVertexCount, sizeof(GLuint), 1, meshFile);

            GLuint uniqueVertexArraySize = uniqueVertexCount * 8 * sizeof(GLfloat);
            GLfloat *uniqueVertexArray = (GLfloat *)malloc(uniqueVertexArraySize);
            fread(uniqueVertexArray, 1, uniqueVertexArraySize, meshFile);

            fclose(meshFile);

            glGenVertexArrays(1, &_vao);
            [self.configuredContext bindVertexArray:_vao];

            glGenBuffers(1, &_bufferSet.vbo);
            glBindBuffer(GL_ARRAY_BUFFER, _bufferSet.vbo);
            glBufferData(GL_ARRAY_BUFFER, uniqueVertexArraySize, uniqueVertexArray, GL_STATIC_DRAW);

            glGenBuffers(1, &_bufferSet.ibo);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufferSet.ibo);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * _indexCount, indexArray, GL_STATIC_DRAW);

            glEnableVertexAttribArray(kRZXVertexAttribPosition);
            glVertexAttribPointer(kRZXVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, (const GLvoid *)0);
            glEnableVertexAttribArray(kRZXVertexAttribNormal);
            glVertexAttribPointer(kRZXVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, (const GLvoid *)12);
            glEnableVertexAttribArray(kRZXVertexAttribTexCoord);
            glVertexAttribPointer(kRZXVertexAttribTexCoord, 2, GL_FLOAT, GL_FALSE, 32, (const GLvoid *)24);

            glBindBuffer(GL_ARRAY_BUFFER, 0);

            free(indexArray);
            free(uniqueVertexArray);

            setup = YES;
        }
    }

#if DEBUG
    setup &= !RZXGLError();
#endif

    return setup;
}

- (BOOL)bindGL
{
    BOOL bound = [super bindGL];

    if ( bound ) {
        [self.configuredContext bindVertexArray:_vao];
    }

#if DEBUG
    bound &= !RZXGLError();
#endif

    return bound;
}

- (void)teardownGL
{
    [super teardownGL];

    _vao = 0;
    _bufferSet.vbo = 0;
    _bufferSet.ibo = 0;
}

#pragma mark - RZXRenderable

- (void)rzx_render
{
    [self bindGL];
    glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_SHORT, NULL);
}

#pragma mark - private methods

- (instancetype)initWithName:(NSString *)name usingCache:(BOOL)usingCache
{
    self = [super init];
    if ( self != nil ) {
        _meshName = [name stringByDeletingPathExtension];
        _usingCache = usingCache;
    }
    return self;
}

@end
