//
//  RZXModelNode.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeScene/RZXModelNode.h>
#import <RazeCore/RZXMaterial.h>
#import <RazeCore/RZXMesh.h>

@implementation RZXModelNode

+ (instancetype)modelNodeWithMesh:(RZXMesh *)mesh
{
    return [[self alloc] initWithMesh:mesh];
}

+ (instancetype)modelNodeWithMesh:(RZXMesh *)mesh texture:(RZXTexture *)texture
{
    return [[self alloc] initWithMesh:mesh texture:texture];
}

+ (instancetype)modelNodeWithMesh:(RZXMesh *)mesh material:(RZXMaterial *)material
{
    return [[self alloc] initWithMesh:mesh material:material];
}

- (instancetype)init
{
    return [self initWithMesh:nil material:nil];
}

- (instancetype)initWithMesh:(RZXMesh *)mesh
{
    return [self initWithMesh:mesh texture:nil];
}

- (instancetype)initWithMesh:(RZXMesh *)mesh texture:(RZXTexture *)texture
{
    if ( (self = [self initWithMesh:mesh material:nil]) ) {
        self.material.texture = texture;
    }
    return self;
}

- (instancetype)initWithMesh:(RZXMesh *)mesh material:(RZXMaterial *)material
{
    if ( (self = [super init]) ) {
        _mesh = mesh;
        _material = material;
    }
    return self;
}

- (RZXMaterial *)material
{
    if ( _material == nil ) {
        _material = [RZXMaterial material];
    }
    return _material;
}

- (RZXMesh *)mesh
{
    if ( _mesh == nil ) {
        _mesh = [[RZXMesh alloc] init];
    }
    return _mesh;
}

#pragma mark - RZXRenderable

- (void)rzx_render
{
    [self.mesh rzx_render];
    
    [super rzx_render];
}

#pragma mark - RZXGPUObject overrides

- (BOOL)setupGL
{
    return ([super setupGL] && [self.material setupGL] && [self.mesh setupGL]);
}

- (BOOL)bindGL
{
    return ([super bindGL] && [self.material bindGL] && [self.mesh bindGL]);
}

- (void)teardownGL
{
    [super teardownGL];

    [self.material teardownGL];
    [self.mesh teardownGL];
}

@end
