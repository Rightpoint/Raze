//
//  RZXSphereCollider.h
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXMath.h>
#import <RazePhysics/RZXCollider.h>

/**
 *  Represents a spherical collision volume.
 */
@interface RZXSphereCollider : RZXCollider

@property (nonatomic, readonly) GLKVector3 center;
@property (nonatomic, readonly) float radius;

+ (instancetype)colliderWithRadius:(float)radius;
+ (instancetype)colliderWithRadius:(float)radius center:(GLKVector3)center;

- (instancetype)initWithRadius:(float)radius;
- (instancetype)initWithRadius:(float)radius center:(GLKVector3)center;

@end
