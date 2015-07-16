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

@interface RZXMesh : RZXGPUObject <RZXRenderable> {
    @protected
    GLuint _vao;
    RZXBufferSet _bufferSet;
    GLuint _indexCount;

    // TODO: this is a hack until meshes are more unified
    BOOL (^_configurationBlock)(RZXMesh *self);
}

@property (nonatomic, readonly) GLKVector3 bounds;

@property (nonatomic, readonly) NSString *cacheKey;

+ (instancetype)meshWithName:(NSString *)name usingCache:(BOOL)useCache;

@end

#pragma clang diagnostic pop
