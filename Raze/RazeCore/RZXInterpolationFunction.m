//
//  RZXInterpolationFunction.m
//  RazeCore
//
//  Created by Rob Visentin on 6/24/15.
//

#import <GLKit/GLKit.h>
#import <RazeCore/NSValue+RZXExtensions.h>

#import "RZXInterpolationFunction.h"

@interface RZXFloatInterpolationFunction : RZXInterpolationFunction
@end

@interface RZXVec2InterpolationFunction : RZXInterpolationFunction
@end

@interface RZXVec3InterpolationFunction : RZXInterpolationFunction
@end

@interface RZXVec4InterpolationFunction : RZXInterpolationFunction
@end

@interface RZXQuaternionInterpolationFunction : RZXInterpolationFunction
@end

@implementation RZXInterpolationFunction

+ (instancetype)floatInterpolator
{
    return [[RZXFloatInterpolationFunction alloc] init];
}

+ (instancetype)vec2Interpolator
{
    return [[RZXVec2InterpolationFunction alloc] init];
}

+ (instancetype)vec3Interpolator
{
    return [[RZXVec3InterpolationFunction alloc] init];
}

+ (instancetype)vec4Interpolator
{
    return [[RZXVec4InterpolationFunction alloc] init];
}

+ (instancetype)quaternionInterpolator
{
    return [[RZXQuaternionInterpolationFunction alloc] init];
}

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t
{
    return nil;
}

@end

@implementation RZXFloatInterpolationFunction

- (id)interpolatedValueFrom:(NSNumber *)fromValue to:(NSNumber *)toValue t:(float)t
{
    return @(fromValue.floatValue + t * (toValue.floatValue - fromValue.floatValue));
}

@end

@implementation RZXVec2InterpolationFunction

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t
{
    GLKVector2 from = [fromValue rzx_vec2Value];
    GLKVector2 to = [toValue rzx_vec2Value];

    return [NSValue rzx_valueWithVec2:GLKVector2Lerp(from, to, t)];
}

@end

@implementation RZXVec3InterpolationFunction

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t
{
    GLKVector3 from = [fromValue rzx_vec3Value];
    GLKVector3 to = [toValue rzx_vec3Value];

    return [NSValue rzx_valueWithVec3:GLKVector3Lerp(from, to, t)];
}

@end

@implementation RZXVec4InterpolationFunction

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t
{
    GLKVector4 from = [fromValue rzx_vec4Value];
    GLKVector4 to = [toValue rzx_vec4Value];

    return [NSValue rzx_valueWithVec4:GLKVector4Lerp(from, to, t)];
}

@end

@implementation RZXQuaternionInterpolationFunction

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t
{
    GLKQuaternion from = [fromValue rzx_quaternionValue];
    GLKQuaternion to = [toValue rzx_quaternionValue];

    return [NSValue rzx_valueWithQuaternion:GLKQuaternionSlerp(from, to, t)];
}

@end
