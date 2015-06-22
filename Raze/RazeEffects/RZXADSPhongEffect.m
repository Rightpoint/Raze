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
                                                            v_normal = normalize(u_normalMatrix * a_normal);
                                                            v_position = vec3(u_MVPMatrix * a_position);
                                                            v_texCoord0 = a_texCoord0;
                                                            gl_Position = vec4(v_position, 1.0);
                                                        }
);

static NSString* const kRZXADSPhongFSH = RZX_SHADER_SRC(
                                                        precision mediump float;
                                                        uniform vec4 u_lightPosition;
                                                        uniform vec3 u_lightIntensity;
                                                        uniform vec3 u_ambientReflection;
                                                        uniform vec3 u_diffuseReflection;
                                                        uniform vec3 u_specularReflection;
                                                        uniform float u_specularShininess;
                                                        uniform sampler2D u_colorMap;
                                                        
                                                        varying vec3 v_position;
                                                        varying vec3 v_normal;
                                                        varying vec2 v_texCoord0;
                                                        
                                                        vec3 ads()
                                                        {
                                                            vec3 n = normalize(v_normal);
                                                            vec3 s = normalize(vec3(u_lightPosition) - v_position);
                                                            vec3 v = normalize(vec3(-v_position));
                                                            vec3 r = reflect(-s,n);
                                                            return u_lightIntensity * (u_ambientReflection + u_diffuseReflection * max(dot(s, n), 0.0) + u_specularReflection * pow(max(dot(r, v), 0.0), u_specularShininess));
                                                        }
                                                        
                                                        void main()
                                                        {
                                                            gl_FragColor = texture2D(u_colorMap, v_texCoord0) * vec4(ads(),1.0);
                                                        }

);

@implementation RZXADSPhongEffect

+ (instancetype)effect
{
    RZXADSPhongEffect *effect = [super effectWithVertexShader:kRZXADSPhongVSH fragmentShader:kRZXADSPhongFSH];
    
    return effect;
}

@end
