//
//  RZXMesh.h
//  RazeCore
//
//  Created by John Stricker on 3/19/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXGPUObject.h>
#import <RazeCore/RZXRenderable.h>

OBJC_EXTERN NSString* const kRZXMeshFileExtension;

@class RZXMesh;
@class RZXVertexAttribute;

typedef struct _RZXBufferSet {
    GLuint vbo, ibo;
} RZXBufferSet;

typedef NSData* (^RZXMeshDataProvider)(id mesh);

/**
 *  Represents an object stored in OpenGL Memory by default loaded from a .mesh file. 
 *  Currently .mesh files are created from Blender via an export script that can be found in the Utilities folder of this SDK.
 */
@interface RZXMesh : RZXGPUObject <RZXRenderable>

/** The render mode used for glDrawElements. Default GL_TRIANGLES. */
@property (assign, nonatomic) GLenum renderMode;

/** The key to use when caching the mesh. */
@property (nonatomic, readonly) NSString *cacheKey;

// Load .mesh file. Use of cache means that if this file has already been loaded, then the buffer values will simply be copied rather then reloading the file and creating a new OpenGL VAO.
/**
 *  Creates a new RZXMesh object.
 *
 *  @param name     The name of the .mesh file to load. The main bundle will be searched for a .mesh file with this name.
 *
 *  @note The mesh checks the cache for an existing VAO object before creating a new one.
 *  If none is found, a new object is created and then cached.
 *
 */
+ (instancetype)meshWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name;

/**
 *  Initialize a new mesh with procedurally generated vertex and optional index data.
 *
 *  @param vertexProvider   Called when the receiver is setup in a GL context. 
 *                          Must return non-nil interleaved vertex data.
 *
 *  @param indexProvider    If non-nil, called when the receiver is setup in a GL context.
 *                          Must return an array of unsigned shorts, or nil if no index data should be used.
 *
 *  @param vertexAttributes An array of RZXVertexAttribute fully specifying the attributes of each vertex.
 */
- (instancetype)initWithVertexProvider:(RZXMeshDataProvider )vertexProvider indexProvider:(RZXMeshDataProvider)indexProvider attributes:(NSArray *)vertexAttributes;

@end

#pragma mark - RZXVertexAttribute

/**
 *  Represents an attribute, e.g. position, normal, or tex coord, of a vertex.
 *  @note Only float attributes are supported.
 */
@interface RZXVertexAttribute : NSObject

/**
 *  The index of the attribute in the shader program.
 */
@property (assign, nonatomic) GLuint index;

/**
 *  The number of floats in the attribute. For example, UV coordinates would have a count of 2.
 */
@property (assign, nonatomic) GLsizei count;

+ (instancetype)attributeWithIndex:(GLuint)index count:(GLsizei)count;
- (instancetype)initWithIndex:(GLuint)index count:(GLsizei)count;

@end
