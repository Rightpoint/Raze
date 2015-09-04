//
//  RZXInterpolator.h
//  RazeAnimation
//
//  Created by Rob Visentin on 6/24/15.
//

#import <Foundation/Foundation.h>

/**
 *  Interploates for the given types of float, vec2, vec3, vec4 and quaternions.
 */
@interface RZXInterpolator : NSObject

+ (instancetype)floatInterpolator;
+ (instancetype)vec2Interpolator;
+ (instancetype)vec3Interpolator;
+ (instancetype)vec4Interpolator;
+ (instancetype)quaternionInterpolator;

- (id)invertValue:(id)value;

- (id)addValue:(id)val1 toValue:(id)val2;

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t;

@end
