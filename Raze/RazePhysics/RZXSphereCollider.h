//
//  RZXSphereCollider.h
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXMath.h>
#import <RazePhysics/RZXCollider.h>

@interface RZXSphereCollider : RZXCollider

@property (nonatomic, readonly) float radius;
@property (nonatomic, readonly) GLKVector3 center;

+ (instancetype)colliderWithRadius:(float)radius;
+ (instancetype)colliderWithRadius:(float)radius center:(GLKVector3)center;

- (instancetype)initWithRadius:(float)radius;
- (instancetype)initWithRadius:(float)radius center:(GLKVector3)center;

@end
