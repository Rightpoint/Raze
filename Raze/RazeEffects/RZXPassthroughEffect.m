//
//  RZXPassthroughEffect.m
//  Raze
//
//  Created by Rob Visentin on 6/19/15.
//
//

#import "RZXPassthroughEffect.h"

NSString* const kRZXEffectPassthroughVSH2D = RZX_SHADER_SRC(
attribute vec4 a_position;
attribute vec2 a_texCoord0;

varying vec2 v_texCoord0;

void main(void)
{
    v_texCoord0 = a_texCoord0;
    gl_Position = a_position;
});

NSString* const kRZXEffectPassthroughVSH3D = RZX_SHADER_SRC(
uniform mat4 u_MVPMatrix;

attribute vec4 a_position;
attribute vec2 a_texCoord0;
                                                        
varying vec2 v_texCoord0;
                                                        
void main(void)
{
    v_texCoord0 = a_texCoord0;
    gl_Position = u_MVPMatrix * a_position;
});

NSString* const kRZXEffectPassthroughFSH = RZX_SHADER_SRC(
uniform lowp sampler2D u_Texture;
                                                      
varying highp vec2 v_texCoord0;
                                                      
void main()
{
    gl_FragColor = texture2D(u_Texture, v_texCoord0);
});

@implementation RZXPassthroughEffect

+ (instancetype)effect2D
{
    RZXPassthroughEffect *effect = [super effectWithVertexShader:kRZXEffectPassthroughVSH2D fragmentShader:kRZXEffectPassthroughFSH];
    effect.mvpUniform = @"u_MVPMatrix";

    return effect;
}

+ (instancetype)effect3D
{
    RZXPassthroughEffect *effect = [super effectWithVertexShader:kRZXEffectPassthroughVSH3D fragmentShader:kRZXEffectPassthroughFSH];
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
