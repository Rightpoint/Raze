//
//  RZXQuadMesh.m
//  RazeCore
//
//  Created by Rob Visentin on 4/30/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//


#import "RZXCubeMesh.h"

const GLfloat kRZXCubeVertices[] = {
    // Front
    0.5f, -0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
    -0.5f, 0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
    // Back
    0.5, -0.5, -0.5f, 0.0f, 0.0f, -1.0f, 1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f,
    -0.5, 0.5, -0.5f, 0.0f, 0.0f, -1.0f, 0.0f, 1.0f,
    0.5f, 0.5f, -0.5f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f,
    // Left
    -0.5f, -0.5f, 0.5f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f,
    -0.5f, 0.5f, -0.5f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f,
    // Right
    0.5f, -0.5f, -0.5f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, -0.5f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f,
    0.5f, 0.5, 0.5, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f,
    0.5, -0.5, 0.5, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f,
    // Top
    0.5, 0.5, 0.5, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f,
    0.5, 0.5, -0.5, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f,
    -0.5, 0.5, -0.5, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f,
    -0.5, 0.5, 0.5, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f,
    // Bottom
    0.5, -0.5, -0.5, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f,
    0.5, -0.5, 0.5, 0.0f, -1.0f, 0.0f, 1.0f, 1.0f,
    -0.5, -0.5, 0.5, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f,
    -0.5, -0.5f, -0.5, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f
};

const GLubyte kRZXCubeIndices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 5, 6,
    6, 7, 4,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
};


@implementation RZXCubeMesh

+ (instancetype)cube
{
    return [[self alloc] init];
}

- (instancetype)init
{
    RZXMeshDataProvider vertexProvider = ^NSData* (id mesh) {
        return [[NSData alloc] initWithBytesNoCopy:kRZXCubeVertices length:sizeof(kRZXCubeVertices) freeWhenDone:NO];
    };

    RZXMeshDataProvider indexProvider = ^NSData* (id mesh) {
        return [[NSData alloc] initWithBytesNoCopy:kRZXCubeIndices length:sizeof(kRZXCubeIndices) freeWhenDone:NO];
    };

    NSArray *attribs = @[ [RZXVertexAttribute attributeWithIndex:kRZXVertexAttribPosition count:3],
                          [RZXVertexAttribute attributeWithIndex:kRZXVertexAttribNormal count:3],
                          [RZXVertexAttribute attributeWithIndex:kRZXVertexAttribTexCoord count:2] ];

    return [super initWithVertexProvider:vertexProvider indexProvider:indexProvider attributes:attribs];
}

- (NSString *)cacheKey
{
    return @"com.raze.mesh-builtin-cube";
}

@end
