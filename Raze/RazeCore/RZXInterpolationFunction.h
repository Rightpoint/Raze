//
//  RZXInterpolationFunction.h
//  RazeCore
//
//  Created by Rob Visentin on 6/24/15.
//

#import <Foundation/Foundation.h>

@interface RZXInterpolationFunction : NSObject

+ (instancetype)floatInterpolator;
+ (instancetype)vec2Interpolator;
+ (instancetype)vec3Interpolator;
+ (instancetype)vec4Interpolator;
+ (instancetype)quaternionInterpolator;

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t;

@end
