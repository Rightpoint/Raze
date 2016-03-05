//
//  RZXCollider_Private.h
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXTransform3D.h>
#import <RazePhysics/RZXCollider.h>

@interface RZXCollider ()

@property (nonatomic, readonly) RZXTransform3D *transform;

- (BOOL)collidesWith:(RZXCollider *)other;
- (BOOL)willCollideWith:(RZXCollider *)other transform:(RZXTransform3D *)transform;

@end
