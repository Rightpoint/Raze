//
//  NSValue+RZXExtensions.m
//  RazeScene
//
//  Created by Rob Visentin on 6/24/15.
//

#import "NSValue+RZXExtensions.h"

@implementation NSValue (RZXExtensions)

+ (instancetype)rzx_valueWithVec2:(GLKVector2)vec2
{
    return [self valueWithBytes:vec2.v objCType:@encode(GLKVector2)];
}

// TODO: finish implementing methods

+ (instancetype)rzx_valueWithQuaternion:(GLKQuaternion)quaternion
{
    return [self valueWithBytes:quaternion.q objCType:@encode(GLKQuaternion)];
}

- (GLKQuaternion)rzx_quaternionValue
{
    GLKQuaternion q;
    [self getValue:q.q];

    return q;
}

@end
