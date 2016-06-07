//
//  RZXCollider.h
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXTransform3D.h>

@class RZXPhysicsWorld;
@class RZXPhysicsBody;

/**
 *  An abstract class representing a collision volume.
 *  Use a concrete subclass that best represents the shape of the physics object.
 */
@interface RZXCollider : NSObject

@property (copy, nonatomic) NSString *identifier;

/**
 *  Whether the collider should take part in physics calculations.
 *  If set to NO, the collider is ignored during the physics pass, and collisions aren't reported.
 *  The default value is YES.
 */
@property (assign, nonatomic, getter=isActive) BOOL active;

/**
 *  The physics body to which the receiver is attached.
 */
@property (weak, nonatomic, readonly) RZXPhysicsBody *body;

/**
 *  The physics world in which the collider exists.
 */
@property (weak, nonatomic, readonly) RZXPhysicsWorld *world;

@end
