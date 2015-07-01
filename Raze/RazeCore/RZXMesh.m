//
//  RZXMesh.m
//  RazeCore
//
//  Created by John Stricker on 3/19/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXMesh.h"

#import <OpenGLES/ES2/glext.h>
#import <RazeCore/RZXVertexObjectData.h>
#import <RazeCore/RZXGLContext.h>

@interface RZXMesh()

@property (copy, nonatomic) NSString *meshName;
@property (copy, nonatomic) NSString *meshFileName;

@property (strong, nonatomic) RZXVertexObjectData *vertexObjectData;

@end

@implementation RZXMesh

+ (instancetype)meshWithName:(NSString *)name meshFileName:(NSString *)meshFileName
{
    return [[self alloc] initWithName:name meshFileName:meshFileName];
}

- (GLKVector3)bounds
{
    return self.vertexObjectData.dimensions;
}

#pragma mark - RZXOpenGLObject

- (void)rzx_setupGL
{
    if ( self.vertexObjectData == nil ) {
        self.vertexObjectData = [RZXVertexObjectData vertexObjectDataWithFileName:_meshFileName];
    }

    [self.vertexObjectData rzx_setupGL];
}

- (void)rzx_bindGL
{
    [self.vertexObjectData rzx_bindGL];
}

- (void)rzx_teardownGL
{
    [self.vertexObjectData rzx_teardownGL];
    self.vertexObjectData = nil;
}

#pragma mark - RZXRenderable

- (void)rzx_render
{
    [self.vertexObjectData rzx_render];
}

#pragma mark - private methods

- (instancetype)initWithName:(NSString *)name meshFileName:(NSString *)meshFileName
{
    self = [super init];
    if ( self != nil ) {
        _meshName = name;
        _meshFileName = meshFileName;
    }
    return self;
}

@end
