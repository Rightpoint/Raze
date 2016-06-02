//
//  RZXPhysicsBody.m
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXPhysicsBody.h>
#import <RazePhysics/RZXPhysicsBody_Private.h>

@implementation RZXPhysicsBody

+ (instancetype)bodyWithCollider:(RZXCollider *)collider
{
    return [[self alloc] initWithCollider:collider];
}

- (instancetype)initWithCollider:(RZXCollider *)collider
{
    if ( (self = [super init]) ) {
        self.collider = collider;
    }
    return self;
}

- (void)setMass:(float)mass
{
    _mass = mass;
    _inverseMass = (mass != 0.0f) ? (1.0f / mass) : 0.0f;
}

- (void)setRestitution:(float)restitution
{
    _restitution = MAX(0.0f, MIN(restitution, 1.0f));
}

- (void)setCollider:(RZXCollider *)collider
{
    _collider.body = nil;
    _collider = collider;
    _collider.body = self;
}

- (void)applyForce:(GLKVector3)force
{
    // TODO: apply the force
}

- (void)applyImpulse:(GLKVector3)impulse
{
    self.velocity = GLKVector3Add(self.velocity, impulse);
}

#pragma mark - private methods

- (RZXContact *)generateContact:(RZXPhysicsBody *)other
{
    RZXContact *contact = nil;

    if ( self.collider != nil && other.collider != nil ) {
        contact = [self.collider generateContact:other.collider];
        contact.first = self;
        contact.second = other;
    }

    return contact;
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    if ( self.isDynamic ) {
        GLKVector3 movement = GLKVector3MultiplyScalar(self.velocity, dt);
        [self.representedObject.transform translateBy:movement];
    }
}

@end
