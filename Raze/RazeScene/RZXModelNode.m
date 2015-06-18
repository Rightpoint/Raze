//
//  RZXModelNode.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXModelNode.h"
#import "RZXMesh.h"

@implementation RZXModelNode

+ (instancetype)modelNodeWithMesh:(RZXMesh *)mesh texture0:(GLuint)texture0
{
    return [[self alloc] initWithMesh:mesh texture0:texture0];
}

- (instancetype)initWithMesh:(RZXMesh *)mesh texture0:(GLuint)texture0
{
    self = [super init];
    if (self) {
        _mesh = mesh;
        _texture0 = texture0;
    }
    return self;
}

- (void)setupGL
{
    [super setupGL];
    [_mesh setupGL];
    
}

- (void)update:(NSTimeInterval)dt
{
    
}

- (void)render
{
    
}


@end
