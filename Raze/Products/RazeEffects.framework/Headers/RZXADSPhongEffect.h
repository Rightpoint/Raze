//
//  RZXADSPhongEffect.h
//  Raze
//
//  Created by John Stricker on 6/22/15.
//
//

#import <RazeCore/RZXEffect.h>

/**
 *  This effect is design for generic purpose display of 3D models. It incorporates a single light, and use ADS (ambient, diffise, and specular) constants to describe the effects of that single light on the model. The lighting effects are applied per fragment (aka Phong shading).
 */

@interface RZXADSPhongEffect : RZXEffect

@property (assign, nonatomic) GLKVector4 lightPosition;
@property (assign, nonatomic) GLKVector3 lightIntensity;
@property (assign, nonatomic) GLKVector3 ambientReflection;
@property (assign, nonatomic) GLKVector3 diffuseReflection;
@property (assign, nonatomic) GLKVector3 specularReflection;
@property (assign, nonatomic) GLfloat specularShininess;

+(instancetype)effect;

@end
