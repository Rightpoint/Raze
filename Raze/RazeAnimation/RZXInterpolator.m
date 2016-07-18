//
//  RZXInterpolator.m
//  RazeAnimation
//
//  Created by Rob Visentin on 6/24/15.
//

#import <GLKit/GLKit.h>
#import <RazeCore/NSValue+RZXExtensions.h>
#import <RazeCore/RZXTransform3D.h>

#import <RazeAnimation/RZXInterpolator.h>

@interface RZXFloatInterpolator : RZXInterpolator
@end

@interface RZXVec2Interpolator : RZXInterpolator
@end

@interface RZXVec3Interpolator : RZXInterpolator
@end

@interface RZXVec4Interpolator : RZXInterpolator
@end

@interface RZXQuaternionInterpolator : RZXInterpolator
@end

@interface RZXTransformInterpolator : RZXInterpolator
@end

@implementation RZXInterpolator

+ (RZXInterpolator *)floatInterpolator
{
    return [[RZXFloatInterpolator alloc] init];
}

+ (RZXInterpolator *)vec2Interpolator
{
    return [[RZXVec2Interpolator alloc] init];
}

+ (RZXInterpolator *)vec3Interpolator
{
    return [[RZXVec3Interpolator alloc] init];
}

+ (RZXInterpolator *)vec4Interpolator
{
    return [[RZXVec4Interpolator alloc] init];
}

+ (RZXInterpolator *)quaternionInterpolator
{
    return [[RZXQuaternionInterpolator alloc] init];
}

+ (RZXInterpolator *)transformInterpolator
{
    return [[RZXTransformInterpolator alloc] init];
}

- (id)invertValue:(id)value
{
    return nil;
}

- (id)addValue:(id)val1 toValue:(id)val2
{
    return nil;
}

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t
{
    return nil;
}

@end

@implementation RZXFloatInterpolator

- (id)invertValue:(NSNumber *)value
{
    return @(-value.floatValue);
}

- (id)addValue:(NSNumber *)val1 toValue:(NSNumber *)val2
{
    return @(val1.floatValue + val2.floatValue);
}

- (id)interpolatedValueFrom:(NSNumber *)fromValue to:(NSNumber *)toValue t:(float)t
{
    return @(fromValue.floatValue + t * (toValue.floatValue - fromValue.floatValue));
}

@end

@implementation RZXVec2Interpolator

- (id)invertValue:(id)value
{
    return [NSValue rzx_valueWithVec2:GLKVector2Negate([value rzx_vec2Value])];
}

- (id)addValue:(id)val1 toValue:(id)val2
{
    GLKVector2 v1 = [val1 rzx_vec2Value];
    GLKVector2 v2 = [val2 rzx_vec2Value];

    return [NSValue rzx_valueWithVec2:GLKVector2Add(v1, v2)];
}

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t
{
    GLKVector2 from = [fromValue rzx_vec2Value];
    GLKVector2 to = [toValue rzx_vec2Value];

    return [NSValue rzx_valueWithVec2:GLKVector2Lerp(from, to, t)];
}

@end

@implementation RZXVec3Interpolator

- (id)invertValue:(id)value
{
    return [NSValue rzx_valueWithVec3:GLKVector3Negate([value rzx_vec3Value])];
}

- (id)addValue:(id)val1 toValue:(id)val2
{
    GLKVector3 v1 = [val1 rzx_vec3Value];
    GLKVector3 v2 = [val2 rzx_vec3Value];

    return [NSValue rzx_valueWithVec3:GLKVector3Add(v1, v2)];
}

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t
{
    GLKVector3 from = [fromValue rzx_vec3Value];
    GLKVector3 to = [toValue rzx_vec3Value];

    return [NSValue rzx_valueWithVec3:GLKVector3Lerp(from, to, t)];
}

@end

@implementation RZXVec4Interpolator

- (id)invertValue:(id)value
{
    return [NSValue rzx_valueWithVec4:GLKVector4Negate([value rzx_vec4Value])];
}

- (id)addValue:(id)val1 toValue:(id)val2
{
    GLKVector4 v1 = [val1 rzx_vec4Value];
    GLKVector4 v2 = [val2 rzx_vec4Value];

    return [NSValue rzx_valueWithVec4:GLKVector4Add(v1, v2)];
}

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t
{
    GLKVector4 from = [fromValue rzx_vec4Value];
    GLKVector4 to = [toValue rzx_vec4Value];

    return [NSValue rzx_valueWithVec4:GLKVector4Lerp(from, to, t)];
}

@end

@implementation RZXQuaternionInterpolator

- (id)invertValue:(id)value
{
    GLKQuaternion q = value ? [value rzx_quaternionValue] : GLKQuaternionIdentity;
    return [NSValue rzx_valueWithQuaternion:GLKQuaternionInvert(q)];
}

- (id)addValue:(id)val1 toValue:(id)val2
{
    GLKQuaternion q1 = val1 ? [val1 rzx_quaternionValue] : GLKQuaternionIdentity;
    GLKQuaternion q2 = val2 ? [val2 rzx_quaternionValue] : GLKQuaternionIdentity;

    return [NSValue rzx_valueWithQuaternion:GLKQuaternionMultiply(q2, q1)];
}

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t
{
    GLKQuaternion from = fromValue ? [fromValue rzx_quaternionValue] : GLKQuaternionIdentity;
    GLKQuaternion to = toValue ? [toValue rzx_quaternionValue] : GLKQuaternionIdentity;

    return [NSValue rzx_valueWithQuaternion:GLKQuaternionSlerp(from, to, t)];
}

@end

@implementation RZXTransformInterpolator

- (id)invertValue:(id)value
{
    return [(RZXTransform3D *)value invertedTransform];
}

- (id)addValue:(id)val1 toValue:(id)val2
{
    RZXTransform3D *result = [(RZXTransform3D *)val2 copy];
    [result transformBy:val1];

    return result;
}

- (id)interpolatedValueFrom:(id)fromValue to:(id)toValue t:(float)t
{
    RZXTransform3D *from = (RZXTransform3D *)fromValue;
    RZXTransform3D *to = (RZXTransform3D *)toValue;
    RZXTransform3D *interpolated = [RZXTransform3D transform];

    interpolated.translation = GLKVector3Lerp(from.translation, to.translation, t);
    interpolated.scale = GLKVector3Lerp(from.scale, to.scale, t);
    interpolated.rotation = GLKQuaternionSlerp(from.rotation, to.rotation, t);

    return interpolated;
}

@end
