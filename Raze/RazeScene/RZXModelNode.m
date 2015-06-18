//
//  RZXModelNode.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>

#import "RZXModelNode.h"
#import "RZXMesh.h"
#import "RZXTexture.h"

@implementation RZXModelNode

+ (instancetype)modelNodeWithMesh:(RZXMesh *)mesh texture:(RZXTexture *)texture
{
    return [[self alloc] initWithMesh:mesh texture:texture];
}

- (instancetype)initWithMesh:(RZXMesh *)mesh texture:(RZXTexture *)texture
{
    self = [super init];
    if (self) {
        _mesh = mesh;
        _texture = texture;
    }
    return self;
}

#pragma mark - RZXRenderable

- (void)render
{
    [self.mesh render];
    
    [super render];
}

#pragma mark - RZXOpenGLObject

- (void)setupGL
{
    [super setupGL];
    [_texture setupGL];
    [_mesh setupGL];
}

- (void)bindGL
{
    [super bindGL];
    [_texture bindGL];
    [_mesh bindGL];
}

- (void)teardownGL
{
    [super teardownGL];
    [_texture teardownGL];
    [_mesh teardownGL];
}

@end
