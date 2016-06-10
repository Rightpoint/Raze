//
//  RZXBoxCollider.h
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXMath.h>
#import <RazePhysics/RZXCollider.h>

/**
 *  Represents an oriented box collision volume.
 */
@interface RZXBoxCollider : RZXCollider

@property (nonatomic, readonly) GLKVector3 size;
@property (nonatomic, readonly) GLKVector3 center;
@property (nonatomic, readonly) GLKQuaternion rotation;

+ (instancetype)colliderWithSize:(GLKVector3)size;
+ (instancetype)colliderWithSize:(GLKVector3)size center:(GLKVector3)center;
+ (instancetype)colliderWithSize:(GLKVector3)size center:(GLKVector3)center rotation:(GLKQuaternion)rotation;

- (instancetype)initWithSize:(GLKVector3)size;
- (instancetype)initWithSize:(GLKVector3)size center:(GLKVector3)center;
- (instancetype)initWithSize:(GLKVector3)size center:(GLKVector3)center rotation:(GLKQuaternion)rotation;

@end
