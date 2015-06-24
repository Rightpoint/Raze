//
//  RZXInterpolationFunction.h
//  RazeScene
//
//  Created by Rob Visentin on 6/24/15.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

@interface RZXInterpolationFunction : NSObject

+ (instancetype)floatInterpolator;
+ (instancetype)vec2Interpolator;
+ (instancetype)vec3Interpolator;
+ (instancetype)vec4Interpolator;
+ (instancetype)quaternionInterpolator;

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(CGFloat)t;

@end
