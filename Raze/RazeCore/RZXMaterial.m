//
//  RZXMaterial.m
//  RazeCore
//
//  Created by Rob Visentin on 5/13/16.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXMaterial.h>
#import <RazeCore/RZXTexture.h>

@implementation RZXMaterial

+ (instancetype)material
{
    return [[self alloc] init];
}

+ (instancetype)materialWithTexture:(RZXTexture *)texture
{
    return [[self alloc] initWithTexture:texture];
}

- (instancetype)init
{
    return [self initWithTexture:nil];
}

- (instancetype)initWithTexture:(RZXTexture *)texture
{
    if ( (self = [super init]) ) {
        _texture = texture;
        _emissionColor = [UIColor clearColor];
        _surfaceColor = [UIColor blackColor];
        _ambientColor = [UIColor whiteColor];
        _diffuseColor = [UIColor whiteColor];
        _specularColor = [UIColor blackColor];
        _blendEnabled = NO;
        _blendSrcRGB = GL_SRC_ALPHA;
        _blendDestRGB = GL_ONE_MINUS_SRC_ALPHA;
    }

    return self;
}

#pragma mark - RZXGPUObject

- (BOOL)setupGL
{
    return [super setupGL] && (self.texture == nil || [self.texture setupGL]);
}

- (BOOL)bindGL
{
    BOOL bound = [super bindGL] && (self.texture == nil || [self.texture bindGL]);

    if ( bound ) {
        RZXGLContext *context = [RZXGLContext currentContext];
        context.blendEnabled = self.isBlendEnabled;

        glBlendFunc(self.blendSrcRGB, self.blendDestRGB);
    }

    return bound;
}

- (void)teardownGL
{
    [super teardownGL];
    [self.texture teardownGL];
}

@end
