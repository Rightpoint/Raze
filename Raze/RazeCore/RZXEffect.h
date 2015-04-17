//
//  RZXEffect.h
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <GLKit/GLKMath.h>
#import <RazeCore/RZXBase.h>

OBJC_EXTERN NSString* const kRZXEffectDefaultVSH2D;
OBJC_EXTERN NSString* const kRZXEffectDefaultVSH3D;

OBJC_EXTERN NSString* const kRZXEffectDefaultFSH;

#define RZX_EFFECT_MAX_DOWNSAMPLE 4

#define RZX_SHADER_SRC(src) (@#src)

@interface RZXEffect : NSObject <RZXOpenGLObject>

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

+ (instancetype)effectWithVertexShaderNamed:(NSString *)vshName fragmentShaderNamed:(NSString *)fshName;

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
