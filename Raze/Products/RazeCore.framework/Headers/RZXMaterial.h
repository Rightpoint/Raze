//
//  RZXMaterial.h
//  RazeCore
//
//  Created by Rob Visentin on 5/13/16.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXGPUObject.h>

@class RZXTexture;

@interface RZXMaterial : RZXGPUObject

/**
 *  An identifier for use by your application.
 */
@property (copy, nonatomic) NSString *name;

/**
 *  The texture to be applied to the material. Default is nil.
 */
@property (strong, nonatomic) RZXTexture *texture;

/**
 *  Color emitted by the surface. Default is clearColor.
 */
@property (nonatomic, strong) RZXColor *emissionColor;

/**
 *  Default surface color. Default is blackColor.
 */
@property (nonatomic, strong) RZXColor *surfaceColor;

/**
 *  Ambient light contribution. Default is whiteColor.
 */
@property (nonatomic, strong) RZXColor *ambientColor;

/**
 *  Diffuse light contribution. Default is whiteColor.
 */
@property (nonatomic, strong) RZXColor *diffuseColor;

/**
 *  Specular light contribution. Default is blackColor.
 */
@property (nonatomic, strong) RZXColor *specularColor;

/**
 *  Exponent for sharpening specular highlights. Default is 0.0.
 */
@property (nonatomic, assign) float shininess;

/**
 *  Whether glBlend should be enabled for this material. Default is NO.
 */
@property (nonatomic, assign, getter = isBlendEnabled) BOOL blendEnabled;

/**
 *  Source RGB factor, applied if blendEnabled = YES. Default is GL_SRC_ALPHA.
 */
@property (nonatomic, assign) GLenum blendSrcRGB;

/**
 *  Destination RGB factor, applied if blendEnabled = YES. Default is GL_ONE_MINUS_SRC_ALPHA.
 */
@property (nonatomic, assign) GLenum blendDestRGB;

+ (instancetype)material;
+ (instancetype)materialWithTexture:(RZXTexture *)texture;

- (instancetype)initWithTexture:(RZXTexture *)texture;

@end
