//
//  RZXModelNode.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXTexture.h>
#import <RazeCore/RZXMesh.h>
#import <RazeScene/RZXModelNode.h>

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

- (RZXTexture *)texture
{
    if ( _texture == nil ) {
        _texture = [[RZXTexture alloc] init];
    }
    return _texture;
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
    return ([super setupGL] && [self.texture setupGL] && [self.mesh setupGL]);
}

- (BOOL)bindGL
{
    return ([super bindGL] && [self.texture bindGL] && [self.mesh bindGL]);
}

- (void)teardownGL
{
    [super teardownGL];

    [self.texture teardownGL];
    [self.mesh teardownGL];
}

@end
