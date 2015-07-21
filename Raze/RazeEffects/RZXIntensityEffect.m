//
//  RZXIntensityEffect.m
//  Raze
//
//  Created by Rob Visentin on 7/21/15.
//
//

#import "RZXIntensityEffect.h"

static NSString* const kRZXEffectIntensityVSH = RZX_SHADER_SRC(
uniform mat4 u_MVPMatrix;

attribute vec4 a_position;
attribute vec2 a_texCoord0;
                                                                   
varying vec2 v_texCoord0;
                                                                   
void main(void)
{
    v_texCoord0 = a_texCoord0;
    gl_Position = u_MVPMatrix * a_position;
});

static NSString* const kRZXEffectIntensityFSH = RZX_SHADER_SRC(
uniform lowp sampler2D u_Texture;

varying highp vec2 v_texCoord0;
                                                                 
void main()
{
    lowp vec4 texel = texture2D(u_Texture, v_texCoord0);
    lowp float intensity = (texel.r + texel.g + texel.b) / 3.0;
    gl_FragColor = vec4(intensity, intensity, intensity, 1.0);
});

@implementation RZXIntensityEffect

+ (instancetype)effect
{
    RZXIntensityEffect *effect = [RZXIntensityEffect effectWithVertexShader:kRZXEffectIntensityVSH fragmentShader:kRZXEffectIntensityFSH];
    effect.mvpUniform = @"u_MVPMatrix";

    return effect;
}

- (BOOL)link
{
    [self bindAttribute:@"a_position" location:kRZXVertexAttribPosition];
    [self bindAttribute:@"a_texCoord0" location:kRZXVertexAttribTexCoord];

    return [super link];
}

@end
