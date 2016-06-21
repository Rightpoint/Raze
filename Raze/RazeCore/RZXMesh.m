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
static NSString* const kRZXMeshAttributeIndexCount = @"RZXQuadMeshIndexCount";
static NSString* const kRZXMeshAttributeVertexCount = @"RZXQuadMeshVertexCount";

NSString* const kRZXMeshFileExtension = @"mesh";

@interface RZXMesh()

// Mutually exclusive with vertex/index providers, depending on the initializer used.
@property (copy, nonatomic) NSString *meshName;

// Mutually exclusive with meshName, depending on the initializer used.
@property (copy, nonatomic) RZXMeshDataProvider vertexProvider;
@property (copy, nonatomic) RZXMeshDataProvider indexProvider;

@property (strong, nonatomic, readwrite) NSArray *vertexAttributes;

@end

@implementation RZXMesh {
    GLuint _vao;
    RZXBufferSet _bufferSet;
    GLuint _indexCount;
    GLsizei _vertexCount;

    BOOL _needsUpdate;
}

+ (instancetype)meshWithName:(NSString *)name
{
    return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    if ( (self = [super init]) ) {
        self.meshName = [name stringByDeletingPathExtension];
        self.renderMode = GL_TRIANGLES;

        self.vertexAttributes = @[ [RZXVertexAttribute attributeWithIndex:kRZXVertexAttribPosition count:3],
                                   [RZXVertexAttribute attributeWithIndex:kRZXVertexAttribNormal count:3],
                                   [RZXVertexAttribute attributeWithIndex:kRZXVertexAttribTexCoord count:2] ];
    }

    return self;
}

- (instancetype)initWithVertexProvider:(RZXMeshDataProvider)vertexProvider indexProvider:(RZXMeshDataProvider)indexProvider attributes:(NSArray *)vertexAttributes
{
    if ( (self = [super init]) ) {
        self.renderMode = GL_TRIANGLES;
        self.vertexProvider = vertexProvider;
        self.indexProvider = indexProvider;
        self.vertexAttributes = vertexAttributes;
    }

    return self;
}

- (NSString *)cacheKey
{
    return self.meshName;
}

- (GLsizei)vertexSize
{
    return [[self.vertexAttributes valueForKeyPath:@"@sum.count"] unsignedIntValue] * sizeof(GLfloat);
}

- (NSData *)vertices
{
    NSData *vertices = nil;

    RZXMeshDataProvider vertexProvider = nil;
    [self getVertexProvider:&vertexProvider indexProvider:NULL];

    if ( vertexProvider != nil ) {
        vertices = vertexProvider(self);
    }

    return vertices;
}

- (void)setNeedsUpdate
{
    if ( self.cacheKey == nil ) {
        _needsUpdate = YES;
    }
}

#pragma mark - RZXGPUObject overrides

- (RZXGPUObjectTeardownBlock)teardownHandler
{
    RZXGPUObjectTeardownBlock teardown = nil;

    RZXCache *cache = [self.configuredContext cacheForClass:[RZXMesh class]];

    if ( cache[self.cacheKey] == nil ) {
        GLuint vao = _vao;
        RZXBufferSet bufferSet = _bufferSet;
        teardown = ^(RZXGLContext *context) {
            [context deleteVertexArrays:&vao count:1];
            glDeleteBuffers(2, &bufferSet.vbo);
        };
    }

    return teardown;
}

- (BOOL)setupGL
{
    BOOL setup = [super setupGL];

    if ( setup ) {
        RZXCache *cache = [self.configuredContext cacheForClass:[RZXMesh class]];

        NSString *cacheKey = self.cacheKey;
        NSDictionary *cachedAttributes = cache[cacheKey];

        if ( cachedAttributes != nil ) {
            [cache retainObjectForKey:cacheKey];
            [self applyCachedAttributes:cachedAttributes];
        }
        else {
            RZXMeshDataProvider vertexProvider = nil;
            RZXMeshDataProvider indexProvider = nil;

            [self getVertexProvider:&vertexProvider indexProvider:&indexProvider];

            setup = [self setupWithVertexProvider:vertexProvider indexProvider:indexProvider];

            if ( setup ) {
                cache[cacheKey] = [self cacheAttributes];
            }
        }
    }

#if RZX_DEBUG
    setup &= !RZXGLError();
#endif

    return setup;
}

- (BOOL)bindGL
{
    BOOL bound = [super bindGL];

    if ( bound ) {
        [self.configuredContext bindVertexArray:_vao];

        if ( _needsUpdate ) {
            [self updateBuffersWithVertexProvider:self.vertexProvider indexProvider:self.indexProvider];
        }
    }

#if RZX_DEBUG
    bound &= !RZXGLError();
#endif

    return bound;
}

- (void)teardownGL
{
    RZXCache *cache = [self.configuredContext cacheForClass:[RZXMesh class]];
    [cache releaseObjectForKey:self.cacheKey];

    _vao = 0;
    _bufferSet.vbo = 0;
    _bufferSet.ibo = 0;
    _indexCount = 0;
    _vertexCount = 0;

    [super teardownGL];
}

#pragma mark - RZXRenderable

- (void)rzx_render
{
    [self bindGL];

    if ( _indexCount > 0 ) {
        glDrawElements(self.renderMode, _indexCount, GL_UNSIGNED_SHORT, NULL);
    }
    else {
        glDrawArrays(self.renderMode, 0, _vertexCount);
    }
}

#pragma mark - private methods

- (void)setVertexAttributes:(NSArray *)vertexAttributes
{
    _vertexAttributes = vertexAttributes;
}

- (NSDictionary *)cacheAttributes
{
    return @{ kRZXMeshAttributeVAO : @(_vao),
              kRZXMeshAttributeIndexCount : @(_indexCount),
              kRZXMeshAttributeVertexCount : @(_vertexCount) };
}

- (void)applyCachedAttributes:(NSDictionary *)attributes
{
    _vao = [attributes[kRZXMeshAttributeVAO] unsignedIntValue];
    _indexCount = [attributes[kRZXMeshAttributeIndexCount] unsignedIntValue];
    _vertexCount = [attributes[kRZXMeshAttributeVertexCount] intValue];
}

- (void)getVertexProvider:(RZXMeshDataProvider *)vertexProvider indexProvider:(RZXMeshDataProvider *)indexProvider
{
    if ( self.meshName.length ) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:self.meshName ofType:kRZXMeshFileExtension];

        if( filePath.length == 0 ) {
            RZXLog(@"Failed to load mesh data from file named %@. Reason: unable to locate %@", self.meshName, [self.meshName stringByAppendingPathExtension:kRZXMeshFileExtension]);
        }
        else {
            FILE *meshFile = fopen([filePath cStringUsingEncoding:NSASCIIStringEncoding], "r");

            // Bounding box isn't saved for now, but still has to be read out
            GLKVector3 bounds;
            fread(&bounds.x, sizeof(GLfloat), 1, meshFile);
            fread(&bounds.y, sizeof(GLfloat), 1, meshFile);
            fread(&bounds.z, sizeof(GLfloat), 1, meshFile);

            fread(&_indexCount, sizeof(GLuint), 1, meshFile);

            size_t indexArraySize = _indexCount * sizeof(GLushort);
            GLushort *indexArray = (GLushort *)malloc(indexArraySize);
            fread(indexArray, 1, _indexCount*sizeof(GLushort), meshFile);

            GLuint uniqueVertexCount;
            fread(&uniqueVertexCount, sizeof(GLuint), 1, meshFile);

            GLuint uniqueVertexArraySize = uniqueVertexCount * 8 * sizeof(GLfloat);
            GLfloat *uniqueVertexArray = (GLfloat *)malloc(uniqueVertexArraySize);
            fread(uniqueVertexArray, 1, uniqueVertexArraySize, meshFile);

            fclose(meshFile);

            NSData *vertexData = [[NSData alloc] initWithBytesNoCopy:uniqueVertexArray length:uniqueVertexArraySize freeWhenDone:YES];

            NSData *indexData = [[NSData alloc] initWithBytesNoCopy:indexArray length:indexArraySize freeWhenDone:YES];

            *vertexProvider = ^NSData* (id mesh) {
                return vertexData;
            };

            *indexProvider = ^NSData* (id mesh) {
                return indexData;
            };
        }
    }
    else {
        *vertexProvider = self.vertexProvider;
        *indexProvider = self.indexProvider;
    }
}

- (BOOL)setupWithVertexProvider:(RZXMeshDataProvider)vertexProvider indexProvider:(RZXMeshDataProvider)indexProvider
{
    BOOL setup = NO;

    if ( vertexProvider != nil ) {
        [self.configuredContext genVertexArrays:&_vao count:1];
        [self.configuredContext bindVertexArray:_vao];

        [self createBuffersWithVertexProvider:vertexProvider indexProvider:indexProvider];

        GLsizei vertexSize = self.vertexSize;
        NSUInteger offset = 0;

        for ( RZXVertexAttribute *attribute in self.vertexAttributes ) {
            glEnableVertexAttribArray(attribute.index);
            glVertexAttribPointer(attribute.index, attribute.count, GL_FLOAT, GL_FALSE, vertexSize, (const GLvoid *)offset);

            offset += attribute.count * sizeof(GLfloat);
        }

        glBindBuffer(GL_ARRAY_BUFFER, 0);

        setup = YES;
    }

    return setup;
}

- (void)createBuffersWithVertexProvider:(RZXMeshDataProvider)vertexProvider indexProvider:(RZXMeshDataProvider)indexProvider
{
    NSData *vertexData = vertexProvider(self);

    _vertexCount = ((GLsizei)vertexData.length / self.vertexSize);

    GLenum bufferUsage = (self.cacheKey == nil) ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW;

    glGenBuffers(1, &_bufferSet.vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _bufferSet.vbo);
    glBufferData(GL_ARRAY_BUFFER, (GLsizeiptr)vertexData.length, vertexData.bytes, bufferUsage);

    if ( indexProvider != nil ) {
        NSData *indexData = indexProvider(self);

        _indexCount = ((GLsizei)indexData.length / sizeof(GLushort));

        if ( indexData != nil ) {
            glGenBuffers(1, &_bufferSet.ibo);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufferSet.ibo);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, (GLsizeiptr)indexData.length, indexData.bytes, bufferUsage);
        }
    }
    else {
        _indexCount = 0;
    }
}

- (void)updateBuffersWithVertexProvider:(RZXMeshDataProvider)vertexProvider indexProvider:(RZXMeshDataProvider)indexProvider
{
    NSData *vertexData = vertexProvider(self);

    _vertexCount = ((GLsizei)vertexData.length / self.vertexSize);

    glBindBuffer(GL_ARRAY_BUFFER, _bufferSet.vbo);
    glBufferSubData(GL_ARRAY_BUFFER, 0, (GLsizeiptr)vertexData.length, vertexData.bytes);

    if ( indexProvider != nil ) {
        NSData *indexData = indexProvider(self);

        _indexCount = ((GLsizei)indexData.length / sizeof(GLushort));

        if ( indexData != nil ) {
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufferSet.ibo);
            glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, (GLsizeiptr)indexData.length, indexData.bytes);
        }
    }
    else {
        _indexCount = 0;
    }
}

@end

#pragma mark - RZXVertexAttribute

@implementation RZXVertexAttribute

+ (instancetype)attributeWithIndex:(GLuint)index count:(GLsizei)count
{
    return [[self alloc] initWithIndex:index count:count];
}

- (instancetype)initWithIndex:(GLuint)index count:(GLsizei)count
{
    if ( (self = [super init]) ) {
        _index = index;
        _count = count;
    }

    return self;
}

@end
