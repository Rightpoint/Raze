//
//  RZXContact.h
//  RazePhysics
//
//  Created by Rob Visentin on 6/2/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXBase.h>

@class RZXPhysicsBody;

@interface RZXContact : NSObject

@property (strong, nonatomic) RZXPhysicsBody *first;
@property (strong, nonatomic) RZXPhysicsBody *second;

/**
 *  The collision normal.
 */
@property (assign, nonatomic) GLKVector3 normal;

/**
 *  Penetration distance.
 */
@property (assign, nonatomic) float distance;

@end
