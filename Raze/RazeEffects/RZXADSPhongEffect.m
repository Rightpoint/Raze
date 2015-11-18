//
//  RZXADSPhongEffect.m
//  Raze
//
//  Created by John Stricker on 6/22/15.
//
//

#import "RZXADSPhongEffect.h"

static NSString* const kRZXADSPhongVSH = RZX_SHADER_SRC(
uniform mat4 u_MVPMatrix;
uniform mat3 u_normalMatrix;

attribute vec4 a_position;
attribute vec3 a_normal;
attribute vec2 a_texCoord0;

varying vec3 v_position;
varying vec3 v_normal;
varying vec2 v_texCoord0;

void main()
{
    vec4 position = u_MVPMatrix * a_position;
    v_normal = normalize(u_normalMatrix * a_normal);
    v_position = vec3(position);
    v_texCoord0 = a_texCoord0;
    gl_Position = position;
}
);

static NSString* const kRZXADSPhongFSH = RZX_SHADER_SRC(
precision mediump float;
uniform highp vec3 u_lightPosition;
uniform vec3 u_lightIntensity;
uniform vec3 u_ambientReflection;
uniform vec3 u_diffuseReflection;
uniform vec3 u_specularReflection;
uniform float u_specularShininess;
uniform lowp sampler2D u_Texture;

varying highp vec3 v_position;
varying highp vec3 v_normal;
varying highp vec2 v_texCoord0;

vec3 ads()
{
    vec3 n = normalize(v_normal);
    vec3 s = normalize(u_lightPosition - v_position);
    vec3 v = normalize(vec3(-v_position));
    vec3 r = reflect(-s,n);
    return u_lightIntensity * (u_ambientReflection + u_diffuseReflection * max(dot(s, n), 0.0) + u_specularReflection * pow(max(dot(r, v), 0.0), u_specularShininess));
}

void main()
{
    gl_FragColor = texture2D(u_Texture, v_texCoord0) * vec4(ads(),1.0);
}
);

@implementation RZXADSPhongEffect

+ (instancetype)effect
{
    RZXADSPhongEffect *effect = [super effectWithVertexShader:kRZXADSPhongVSH fragmentShader:kRZXADSPhongFSH];
    
    effect.lightPosition = GLKVector3Make(0.0f, 0.0f, 10.0f);
    effect.lightIntensity = GLKVector3Make(1.0f, 1.0f, 1.0f);
    effect.ambientReflection = GLKVector3Make(0.5f, 0.5f, 0.5f);
    effect.diffuseReflection = GLKVector3Make(0.5f, 0.5f, 0.5f);
    effect.specularReflection = GLKVector3Make(0.5f, 0.5f, 0.5f);
    effect.specularShininess = 1.0f;

    effect.mvpUniform = @"u_MVPMatrix";
    effect.normalMatrixUniform = @"u_normalMatrix";
    
    return effect;
}


- (BOOL)link
{
    [self bindAttribute:@"a_position" location:kRZXVertexAttribPosition];
    [self bindAttribute:@"a_normal" location:kRZXVertexAttribNormal];
    [self bindAttribute:@"a_texCoord0" location:kRZXVertexAttribTexCoord];
    
    return [super link];
}

- (BOOL)prepareToDraw
{
    BOOL ret = [super prepareToDraw];

    [self setFloatUniform:@"u_lightPosition" value:_lightPosition.v length:3 count:1];
    [self setFloatUniform:@"u_lightIntensity" value:_lightIntensity.v length:3 count:1];
    [self setFloatUniform:@"u_ambientReflection" value:_ambientReflection.v length:3 count:1];
    [self setFloatUniform:@"u_diffuseReflection" value:_diffuseReflection.v length:3 count:1];
    [self setFloatUniform:@"u_specularReflection" value:_specularReflection.v length:3 count:1];
    [self setFloatUniform:@"u_specularShininess" value:&_specularShininess length:1 count:1];

     return ret;
}

@end
