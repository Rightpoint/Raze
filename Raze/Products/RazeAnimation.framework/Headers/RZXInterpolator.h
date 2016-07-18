//
//  RZXInterpolator.h
//  RazeAnimation
//
//  Created by Rob Visentin on 6/24/15.
//

#import <Foundation/Foundation.h>

@interface RZXInterpolator : NSObject

+ (RZXInterpolator *)floatInterpolator;
+ (RZXInterpolator *)vec2Interpolator;
+ (RZXInterpolator *)vec3Interpolator;
+ (RZXInterpolator *)vec4Interpolator;
+ (RZXInterpolator *)quaternionInterpolator;
+ (RZXInterpolator *)transformInterpolator;

- (id)invertValue:(id)value;

- (id)addValue:(id)val1 toValue:(id)val2;

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t;

@end
