//
//  RZXMesh.m
//  RazeCore
//
//  Created by John Stricker on 3/19/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXMesh.h>
#import <RazeCore/RZXCache.h>

static NSString* const kRZXMeshAttributeVAO = @"RZXQuadMeshName";
static NSString* const kRZXMeshAttributeIndices = @"RZXQuadMeshIndices";

NSString* const kRZXMeshFileExtension = @"mesh";

@interface RZXMesh()

@property (copy, nonatomic) NSString *meshName;
@property (assign, nonatomic) BOOL usingCache;

@end

@implementation RZXMesh

+ (instancetype)meshWithName:(NSString *)name usingCache:(BOOL)useCache
{
    RZXMesh *mesh = [[self alloc] init];
    mesh.usingCache = useCache;
    mesh.meshName = [name stringByDeletingPathExtension];

    return mesh;
}

- (NSString *)cacheKey
{
    return self.meshName;
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
        RZXCache *cache = self.usingCache ? [self.configuredContext cacheForClass:[RZXMesh class]] : nil;

        NSString *cacheKey = self.cacheKey;
        NSDictionary *cachedAttributes = [cache objectForKey:cacheKey];

        if ( cachedAttributes != nil ) {
            [cache retainObjectForKey:cacheKey];
            [self applyCachedAttributes:cachedAttributes];
        }
        else {
            if ( self.meshName.length ) {
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
                }
            }
            else if ( _configurationBlock != nil ) {
                setup = _configurationBlock(self);
            }

            if ( setup && self.usingCache ) {
                [cache cacheObject:[self cacheAttributes] forKey:self.cacheKey];
            }
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
    if ( self.usingCache ) {
        RZXCache *cache = [self.configuredContext cacheForClass:[RZXMesh class]];
        [cache releaseObjectForKey:self.cacheKey];
    }

    _vao = 0;
    _bufferSet.vbo = 0;
    _bufferSet.ibo = 0;

    [super teardownGL];
}

#pragma mark - RZXRenderable

- (void)rzx_render
{
    [self bindGL];
    glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_SHORT, NULL);
}

#pragma mark - private methods

- (instancetype)init
{
    if ( (self = [super init]) ) {
        _usingCache = YES;
    }
    return self;
}

- (NSDictionary *)cacheAttributes
{
    return @{ kRZXMeshAttributeVAO : @(_vao), kRZXMeshAttributeIndices : @(_indexCount) };
}

- (void)applyCachedAttributes:(NSDictionary *)attributes
{
    _vao = [attributes[kRZXMeshAttributeVAO] unsignedIntValue];
    _indexCount = [attributes[kRZXMeshAttributeIndices] unsignedIntValue];
}

@end
