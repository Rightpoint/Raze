//
//  NSValue+RZXExtensions.h
//  RazeCore
//
//  Created by Rob Visentin on 6/24/15.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMathTypes.h>

@interface NSValue (RZXExtensions)

+ (instancetype)rzx_valueWithVec2:(GLKVector2)vec2;
+ (instancetype)rzx_valueWithVec3:(GLKVector3)vec3;
+ (instancetype)rzx_valueWithVec4:(GLKVector4)vec4;
+ (instancetype)rzx_valueWithQuaternion:(GLKQuaternion)quaternion;

- (GLKVector2)rzx_vec2Value;
- (GLKVector3)rzx_vec3Value;
- (GLKVector4)rzx_vec4Value;
- (GLKQuaternion)rzx_quaternionValue;

@end
