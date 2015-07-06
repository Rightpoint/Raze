//
//  RZXModelNode.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <OpenGLES/ES2/glext.h>
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

#pragma mark - RZXRenderable

- (void)rzx_render
{
    [self.mesh rzx_render];
    
    [super rzx_render];
}

#pragma mark - RZXOpenGLObject

- (void)rzx_setupGL
{
    [super rzx_setupGL];

    [self.texture rzx_setupGL];
    [self.mesh rzx_setupGL];
}

- (void)rzx_bindGL
{
    [super rzx_bindGL];

    [self.texture rzx_bindGL];
    [self.mesh rzx_bindGL];
}

- (void)rzx_teardownGL
{
    [super rzx_teardownGL];

    [self.texture rzx_teardownGL];
    [self.mesh rzx_teardownGL];
}

@end
