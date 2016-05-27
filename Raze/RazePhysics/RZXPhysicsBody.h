//
//  RZXPhysicsBody.h
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCollider.h>

@protocol RZXPhysicsObject;

@interface RZXPhysicsBody : NSObject

@property (strong, nonatomic) id<RZXPhysicsObject> representedObject;

@property (strong, nonatomic) RZXCollider *collider;

@property (weak, nonatomic, readonly) RZXPhysicsWorld *world;

+ (instancetype)bodyWithCollider:(RZXCollider *)collider;

- (instancetype)initWithCollider:(RZXCollider *)collider;

@end

@protocol RZXPhysicsObject <NSObject>

@property (nonatomic, readonly) RZXTransform3D *transform;
@property (nonatomic, readonly) RZXTransform3D *worldTransform;

@end
