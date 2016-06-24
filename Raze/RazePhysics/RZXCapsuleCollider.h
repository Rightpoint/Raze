//
//  RZXCapsuleCollider.h
//  RazePhysics
//
//  Created by Rob Visentin on 6/24/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCollider.h>

@interface RZXCapsuleCollider : RZXCollider

@property (nonatomic, readonly) GLKVector3 center;
@property (nonatomic, readonly) GLKVector3 axis;
@property (nonatomic, readonly) float radius;

+ (instancetype)colliderWithAxis:(GLKVector3)axis radius:(float)radius;
+ (instancetype)colliderWithAxis:(GLKVector3)axis radius:(float)radius center:(GLKVector3)center;

- (instancetype)initWithAxis:(GLKVector3)axis radius:(float)radius;
- (instancetype)initWithAxis:(GLKVector3)axis radius:(float)radius center:(GLKVector3)center;

@end
