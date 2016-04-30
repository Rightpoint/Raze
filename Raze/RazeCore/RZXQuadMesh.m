//
//  RZXQuadMesh.m
//  RazeCore
//
//  Created by Rob Visentin on 1/10/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXQuadMesh.h>

NSInteger const kRZXQuadMeshMaxSubdivisions = 8;

void RZXGenerateQuadMeshIndices(NSInteger subdivisions, GLvoid **indices, GLuint *numIndices);
void RZXGenerateQuadMeshVertices(NSInteger subdivisions, GLvoid **vertices, GLuint *numVerts);

@interface RZXQuadMesh ()

@property (assign, nonatomic) NSInteger subdivisions;

@end

@implementation RZXQuadMesh

#pragma mark - lifecycle

+ (instancetype)quad
{
    return [[self alloc] init];
}

+ (instancetype)quadWithSubdivisionLevel:(NSInteger)subdivisons
{
    return [[self alloc] initWithSubdivisionLevel:subdivisons];
}

- (instancetype)init
{
    return [self initWithSubdivisionLevel:0];
}

- (instancetype)initWithSubdivisionLevel:(NSInteger)subdivisions
{
    RZXMeshDataProvider vertexProvider = ^NSData* (RZXQuadMesh *mesh) {
        GLvoid *vertexData;
        GLuint vertexCount;
        RZXGenerateQuadMeshVertices(mesh.subdivisions, &vertexData, &vertexCount);

        return [[NSData alloc] initWithBytesNoCopy:vertexData length:8 * vertexCount * sizeof(GLfloat) freeWhenDone:YES];
    };

    RZXMeshDataProvider indexProvider = ^NSData* (RZXQuadMesh *mesh) {
        GLvoid *indexData;
        GLuint indexCount;
        RZXGenerateQuadMeshIndices(mesh.subdivisions, &indexData, &indexCount);

        return [[NSData alloc] initWithBytesNoCopy:indexData length:indexCount * sizeof(GLushort) freeWhenDone:YES];
    };

    NSArray *attribs = @[ [RZXVertexAttribute attributeWithIndex:kRZXVertexAttribPosition count:3],
                          [RZXVertexAttribute attributeWithIndex:kRZXVertexAttribNormal count:3],
                          [RZXVertexAttribute attributeWithIndex:kRZXVertexAttribTexCoord count:2] ];

    self = [super initWithVertexProvider:vertexProvider indexProvider:indexProvider attributes:attribs];
    if ( self ) {
        subdivisions = MAX(0, MIN(subdivisions, kRZXQuadMeshMaxSubdivisions));
        _subdivisions = subdivisions;
    }
    return self;
}

#pragma mark - getters

- (NSString *)cacheKey
{
    return [NSString stringWithFormat:@"com.raze.mesh-builtin-quad-%i", (int)self.subdivisions];
}

@end

#pragma mark - private functions

void RZXGenerateQuadMeshIndices(NSInteger subdivisions, GLvoid **indices, GLuint *numIndices)
{
    GLuint subs = pow(2.0, subdivisions);
    GLuint pts = subs + 1;

    *numIndices = 6 * subs * subs;

    GLushort *idxs = (GLushort *)malloc(*numIndices * sizeof(GLushort));

    int i = 0;

    for ( int y = 0; y < pts; y++ ) {
        for ( int x = 0; x < pts; x++ ) {
            if ( x < subs && y < subs ) {
                idxs[i++] = y * pts + x;
                idxs[i++] = (y + 1) * pts + x;
                idxs[i++] = y * pts + x + 1;
                idxs[i++] = y * pts + x + 1;
                idxs[i++] = (y + 1) * pts + x;
                idxs[i++] = (y + 1) * pts + x + 1;
            }
        }
    }

    *indices = idxs;
}

void RZXGenerateQuadMeshVertices(NSInteger subdivisions, GLvoid **vertices, GLuint *numVerts)
{
    GLuint subs = pow(2.0, subdivisions);
    GLuint pts = subs + 1;

    GLfloat ptStep = 2.0f / subs;
    GLfloat texStep = 1.0f / subs;

    *numVerts = pts * pts;

    GLfloat *verts = (GLfloat *)malloc(8 * *numVerts * sizeof(GLfloat));

    int v = 0;

    for ( int y = 0; y < pts; y++ ) {
        for ( int x = 0; x < pts; x++ ) {
            // Position
            verts[v++] = -1.0f + ptStep * x;
            verts[v++] = 1.0f - ptStep * y;
            verts[v++] = 0.0f;

            // Normal
            verts[v++] = 0.0f;
            verts[v++] = 0.0f;
            verts[v++] = 1.0f;

            // Tex coord
            verts[v++] = texStep * x;
            verts[v++] = 1.0f - texStep * y;
        }
    }
    
    *vertices = verts;
}
