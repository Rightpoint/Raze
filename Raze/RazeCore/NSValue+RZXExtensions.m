//
//  NSValue+RZXExtensions.m
//  RazeCore
//
//  Created by Rob Visentin on 6/24/15.
//

#import "NSValue+RZXExtensions.h"

@implementation NSValue (RZXExtensions)

+ (instancetype)rzx_valueWithVec2:(GLKVector2)vec2
{
    return [self valueWithBytes:vec2.v objCType:@encode(GLKVector2)];
}

+ (instancetype)rzx_valueWithVec3:(GLKVector3)vec3
{
    return [self valueWithBytes:vec3.v objCType:@encode(GLKVector3)];
}

+ (instancetype)rzx_valueWithVec4:(GLKVector4)vec4
{
    return [self valueWithBytes:vec4.v objCType:@encode(GLKVector4)];
}

+ (instancetype)rzx_valueWithQuaternion:(GLKQuaternion)quaternion
{
    return [self valueWithBytes:quaternion.q objCType:@encode(GLKQuaternion)];
}

- (GLKVector2)rzx_vec2Value
{
    GLKVector2 v;
    [self getValue:v.v];
    return v;
}

- (GLKVector3)rzx_vec3Value
{
    GLKVector3 v;
    [self getValue:v.v];
    return v;
}

- (GLKVector4)rzx_vec4Value
{
    GLKVector4 v;
    [self getValue:v.v];
    return v;
}

- (GLKQuaternion)rzx_quaternionValue
{
    GLKQuaternion q;
    [self getValue:q.q];
    return q;
}

@end
