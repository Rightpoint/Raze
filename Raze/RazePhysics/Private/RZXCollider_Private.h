//
//  RZXCollider_Private.h
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCollider.h>
#import <RazePhysics/RZXGeometry.h>

@interface RZXCollider ()

@property (nonatomic, readonly) RZXBox boundingBox;
@property (nonatomic, readonly) RZXSphere boundingSphere;

@property (copy, nonatomic) RZXTransform3D *transform;
@property (copy, nonatomic) RZXTransform3D *previousTransform;

@property (weak, nonatomic) RZXPhysicsBody *body;
@property (weak, nonatomic) RZXPhysicsWorld *world;

// For RZXScene integration
- (void)revertToPreviousTransform;

- (BOOL)pointInside:(GLKVector3)point;
- (BOOL)collidesWith:(RZXCollider *)other;

@end
