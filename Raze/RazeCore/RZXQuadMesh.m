//
//  RZXQuadMesh.m
//  RazeCore
//
//  Created by Rob Visentin on 1/10/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXQuadMesh.h>

NSInteger const kRZXQuadMeshMaxSubdivisions = 8;

void RZXGenerateQuadMesh(NSInteger subdivisions, GLvoid **vertices, GLuint *numVerts, GLvoid **indices, GLuint *numIdxs);

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
    self = [super init];
    if ( self ) {
        subdivisions = MAX(0, MIN(subdivisions, kRZXQuadMeshMaxSubdivisions));
        _subdivisions = subdivisions;

        _configurationBlock = ^BOOL (RZXMesh *self) {
            GLvoid *vertexData, *indexData;
            GLuint vertexCount;
            RZXGenerateQuadMesh(subdivisions, &vertexData, &vertexCount, &indexData, &self->_indexCount);

            [self.configuredContext genVertexArrays:&self->_vao count:1];
            glGenBuffers(2, &self->_bufferSet.vbo);

            [self.configuredContext bindVertexArray:self->_vao];

            glBindBuffer(GL_ARRAY_BUFFER, self->_bufferSet.vbo);
            glBufferData(GL_ARRAY_BUFFER, 8 * vertexCount * sizeof(GLfloat), vertexData, GL_STATIC_DRAW);

            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self->_bufferSet.ibo);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, self->_indexCount * sizeof(GLushort), indexData, GL_STATIC_DRAW);

            glEnableVertexAttribArray(kRZXVertexAttribPosition);
            glVertexAttribPointer(kRZXVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (const GLvoid *)0);

            glEnableVertexAttribArray(kRZXVertexAttribTexCoord);
            glVertexAttribPointer(kRZXVertexAttribTexCoord, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (const GLvoid *)12);

            glEnableVertexAttribArray(kRZXVertexAttribNormal);
            glVertexAttribPointer(kRZXVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (const GLvoid *)20);

            glBindBuffer(GL_ARRAY_BUFFER, 0);

            free(vertexData);
            free(indexData);
            
            return YES;
        };
    }
    return self;
}

#pragma mark - getters

- (GLKVector3)bounds
{
    return (GLKVector3){2.0f, 2.0f, 0.0f};
}

- (NSString *)cacheKey
{
    return [NSString stringWithFormat:@"com.raze.mesh-builtin-quad-%i", (int)self.subdivisions];
}

void RZXGenerateQuadMesh(NSInteger subdivisions, GLvoid **vertices, GLuint *numVerts, GLvoid **indices, GLuint *numIdxs)
{
    GLuint subs = pow(2.0, subdivisions);
    GLuint pts = subs + 1;
    
    GLfloat ptStep = 2.0f / subs;
    GLfloat texStep = 1.0f / subs;
    
    *numVerts = pts * pts;
    *numIdxs = 6 * subs * subs;
    
    GLfloat *verts = (GLfloat *)malloc(8 * *numVerts * sizeof(GLfloat));
    GLushort *idxs = (GLushort *)malloc(*numIdxs * sizeof(GLushort));
    
    int v = 0;
    int i = 0;
    
    for ( int y = 0; y < pts; y++ ) {
        for ( int x = 0; x < pts; x++ ) {
            verts[v++] = -1.0f + ptStep * x;
            verts[v++] = 1.0f - ptStep * y;
            verts[v++] = 0.0f;
            verts[v++] = texStep * x;
            verts[v++] = 1.0f - texStep * y;

            verts[v++] = 0.0f;
            verts[v++] = 0.0f;
            verts[v++] = 1.0f;
            
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

    *vertices = verts;
    *indices = idxs;
}

@end
