//
//  RZXConvolutionEffect.m
//  RazeEffects
//
//  Created by Rob Visentin on 7/23/15.
//

#import <RazeEffects/RZXConvolutionEffect.h>

const GLKMatrix3 kRZXConvoultionKernelIdentity = (GLKMatrix3){0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f};

NSString* const kRZXEffectConvolutionVSH = RZX_SHADER_SRC(
uniform mat4 u_MVPMatrix;
uniform vec2 u_Step;

attribute vec4 a_position;
attribute vec2 a_texCoord0;
                                                            
varying vec2 v_texCoords[9];
                                                            
void main(void)
{
    v_texCoords[0] = a_texCoord0;
    v_texCoords[1] = a_texCoord0 - vec2(u_Step.x, 0.0);
    v_texCoords[2] = a_texCoord0 - u_Step;
    v_texCoords[3] = a_texCoord0 - vec2(0.0, u_Step.y);
    v_texCoords[4] = a_texCoord0 + vec2(u_Step.x, -u_Step.y);
    v_texCoords[5] = a_texCoord0 + vec2(u_Step.x, 0.0);
    v_texCoords[6] = a_texCoord0 + u_Step;
    v_texCoords[7] = a_texCoord0 + vec2(0.0, u_Step.y);
    v_texCoords[8] = a_texCoord0 + vec2(-u_Step.x, u_Step.y);

    gl_Position = u_MVPMatrix * a_position;
});

static NSString* const kRZXEffectConvolutionFSHStart = RZX_SHADER_SRC(
uniform highp mat3 u_Convolution;

uniform lowp sampler2D u_Texture;

varying highp vec2 v_texCoords[9];

void main()
{
    lowp vec4 center      = texture2D(u_Texture, v_texCoords[0]);
    lowp vec3 left        = texture2D(u_Texture, v_texCoords[1]).rgb;
    lowp vec3 topLeft     = texture2D(u_Texture, v_texCoords[2]).rgb;
    lowp vec3 top         = texture2D(u_Texture, v_texCoords[3]).rgb;
    lowp vec3 topRight    = texture2D(u_Texture, v_texCoords[4]).rgb;
    lowp vec3 right       = texture2D(u_Texture, v_texCoords[5]).rgb;
    lowp vec3 bottomRight = texture2D(u_Texture, v_texCoords[6]).rgb;
    lowp vec3 bottom      = texture2D(u_Texture, v_texCoords[7]).rgb;
    lowp vec3 bottomLeft  = texture2D(u_Texture, v_texCoords[8]).rgb;
    
    highp vec3 rgb = topLeft * u_Convolution[0][0] + top * u_Convolution[1][0] + topRight * u_Convolution[2][0];
    rgb += left * u_Convolution[0][1] + center.rgb * u_Convolution[1][1] + right * u_Convolution[2][1];
    rgb += bottomLeft * u_Convolution[0][2] + bottom * u_Convolution[1][2] + bottomRight * u_Convolution[2][2];
);

static NSString* const kRZXEffectConvolutionFSHEnd = RZX_SHADER_SRC(
    gl_FragColor = vec4(rgb, center.a);
});

@implementation RZXConvolutionEffect

+ (instancetype)effectWithKernel:(GLKMatrix3)kernel postProcessing:(NSString *)postProcessingSrc
{
    NSString *fsh = [NSString stringWithFormat:@"%@%@;\n%@", kRZXEffectConvolutionFSHStart, postProcessingSrc ?: @"", kRZXEffectConvolutionFSHEnd];

    RZXConvolutionEffect *effect = [RZXConvolutionEffect effectWithVertexShader:kRZXEffectConvolutionVSH fragmentShader:fsh];
    effect.mvpUniform = @"u_MVPMatrix";
    effect.kernel = kernel;

    return effect;
}

- (BOOL)link
{
    [self bindAttribute:@"a_position" location:kRZXVertexAttribPosition];
    [self bindAttribute:@"a_texCoord0" location:kRZXVertexAttribTexCoord];

    return [super link];
}
- (BOOL)prepareToDraw
{
    GLKVector2 step = GLKVector2Make(1.0f / self.resolution.x, 1.0f / self.resolution.y);
    [self setFloatUniform:@"u_Step" value:step.v length:2 count:1];

    [self setMatrix3Uniform:@"u_Convolution" value:&_kernel transpose:GL_FALSE count:1];

    return [super prepareToDraw];
}

@end
