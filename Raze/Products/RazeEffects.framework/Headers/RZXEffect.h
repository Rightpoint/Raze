//
//  RZXEffect.h
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXGPUObject.h>

#define RZX_EFFECT_MAX_DOWNSAMPLE 4

#define RZX_SHADER_SRC(src) (@#src)

/**
 *  Manages a shader. Any new shaders should subclass this. Override link to set up attributes (and call super), and override preprare to draw to assign uniforms (and call super). See RZXADSPhongEffect for an example of how a typical OpenGL shader can be implemented.
 */
@interface RZXEffect : RZXGPUObject

@property (nonatomic, readonly, getter = isLinked) BOOL linked;

@property (assign, nonatomic) GLKMatrix4 modelViewMatrix;
@property (assign, nonatomic) GLKMatrix4 projectionMatrix;
@property (assign, nonatomic) GLKMatrix3 normalMatrix;

@property (copy, nonatomic) NSString *mvpUniform;
@property (copy, nonatomic) NSString *mvUniform;
@property (copy, nonatomic) NSString *normalMatrixUniform;

@property (assign, nonatomic) GLKVector2 resolution;
@property (assign, nonatomic) GLuint downsampleLevel;

@property (nonatomic, readonly) NSInteger preferredLevelOfDetail;

+ (instancetype)effectWithVertexShader:(NSString *)vsh fragmentShader:(NSString *)fsh;

- (BOOL)link;

- (BOOL)prepareToDraw;

- (void)bindAttribute:(NSString *)attribute location:(GLuint)location;
- (GLint)uniformLoc:(NSString *)uniformName;

- (void)setFloatUniform:(NSString *)name value:(const GLfloat *)value length:(GLsizei)length count:(GLsizei)count;

- (void)setIntUniform:(NSString *)name value:(const GLint *)value length:(GLsizei)length count:(GLsizei)count;

- (void)setMatrix2Uniform:(NSString *)name value:(const GLKMatrix2 *)value transpose:(GLboolean)transpose count:(GLsizei)count;
- (void)setMatrix3Uniform:(NSString *)name value:(const GLKMatrix3 *)value transpose:(GLboolean)transpose count:(GLsizei)count;
- (void)setMatrix4Uniform:(NSString *)name value:(const GLKMatrix4 *)value transpose:(GLboolean)transpose count:(GLsizei)count;

@end
