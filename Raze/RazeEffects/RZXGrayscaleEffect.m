//
//  RZXGrayscaleEffect.m
//  RazeEffects
//
//  Created by Rob Visentin on 7/21/15.
//

#import "RZXGrayscaleEffect.h"

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
const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

uniform lowp sampler2D u_Texture;

varying highp vec2 v_texCoord0;
                                                                 
void main()
{
    lowp vec4 texel = texture2D(u_Texture, v_texCoord0);
    highp float luminance = dot(texel.rgb, W);
    gl_FragColor = vec4(vec3(luminance), texel.a);
});

@implementation RZXGrayscaleEffect

+ (instancetype)effect
{
    RZXGrayscaleEffect *effect = [RZXGrayscaleEffect effectWithVertexShader:kRZXEffectIntensityVSH fragmentShader:kRZXEffectIntensityFSH];
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
