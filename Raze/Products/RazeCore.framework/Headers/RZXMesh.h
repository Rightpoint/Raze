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

typedef struct _RZXBufferSet {
    GLuint vbo, ibo;
} RZXBufferSet;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"

/**
 *  Represents an object stored in OpenGL Memory by default loaded from a .mesh file. 
 *  Currently .mesh files are created from Blender via an export script that can be found in the Utilities folder of this SDK.
 */
@interface RZXMesh : RZXGPUObject <RZXRenderable> {
    @protected
    GLuint _vao;
    RZXBufferSet _bufferSet;
    GLuint _indexCount;

    // TODO: this is a hack until meshes are more unified
    BOOL (^_configurationBlock)(RZXMesh *self);
}

/** Max width, height, and depth of the mesh. */
@property (nonatomic, readonly) GLKVector3 bounds;

/** The key to use when caching the mesh. */
@property (nonatomic, readonly) NSString *cacheKey;

// Load .mesh file. Use of cache means that if this file has already been loaded, then the buffer values will simply be copied rather then reloading the file and creating a new OpenGL VAO.
/**
 *  Creates a new RZXMesh object.
 *
 *  @param name     The name of the .mesh file to load. The main bundle will be searched for a .mesh file with this name.
 *  @param useCache If YES, the mesh checks the cache for an existing VAO object before creating a new one. 
 *  If none is found, a new object is created and then cached.
 *
 */
+ (instancetype)meshWithName:(NSString *)name usingCache:(BOOL)useCache;

@end

#pragma clang diagnostic pop
