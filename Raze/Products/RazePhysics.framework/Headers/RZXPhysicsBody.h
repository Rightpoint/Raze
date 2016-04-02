//
//  RZXPhysicsBody.h
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCollider.h>

@interface RZXPhysicsBody : NSObject

@property (strong, nonatomic) RZXCollider *collider;

+ (instancetype)bodyWithCollider:(RZXCollider *)collider;

- (instancetype)initWithCollider:(RZXCollider *)collider;

@end
