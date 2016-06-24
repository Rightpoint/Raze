//
//  RZXPhysicsBody.m
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXPhysicsBody.h>
#import <RazePhysics/RZXPhysicsBody_Private.h>

@implementation RZXPhysicsBody {
    NSHashTable *_contactedBodies;
    float _inverseMass;
}

+ (instancetype)bodyWithCollider:(RZXCollider *)collider
{
    return [[self alloc] initWithCollider:collider];
}

- (instancetype)init
{
    if ( (self = [super init]) ) {
        _contactedBodies = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory | NSPointerFunctionsObjectPointerPersonality];
        _mass = 1.0f;
        _inverseMass = 1.0f;
        _dynamic = YES;
        _affectedByGravity = YES;
    }
    return self;
}

- (instancetype)initWithCollider:(RZXCollider *)collider
{
    if ( (self = [self init]) ) {
        self.collider = collider;
    }
    return self;
}

- (NSSet *)contactedBodies
{
    return [_contactedBodies setRepresentation];
}

- (void)setMass:(float)mass
{
    _mass = MAX(0.0f, mass);
    _inverseMass = (mass != 0.0f) ? (1.0f / mass) : INFINITY;
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

- (void)applyImpulse:(GLKVector3)impulse
{
    [self adjustVelocity:GLKVector3MultiplyScalar(impulse, self.inverseMass)];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    RZXPhysicsBody *copy = [[[self class] alloc] init];

    copy.name = self.name;
    copy.collider = [self.collider copy];
    copy.mass = self.mass;
    copy.restitution = self.restitution;
    copy.velocity = self.velocity;
    copy.dynamic = self.isDynamic;
    copy.affectedByGravity = self.isAffectedByGravity;

    return copy;
}

#pragma mark - private methods

- (float)inverseMass
{
    // non-dynamic bodies are treated as if they have infinite mass
    return self.isDynamic ? _inverseMass : 0.0f;
}

- (void)adjustVelocity:(GLKVector3)dv
{
    self.velocity = GLKVector3Add(self.velocity, dv);
}

- (void)adjustPosition:(GLKVector3)movement
{
    [self.representedObject.transform translateBy:movement];
}

- (void)prepareForUpdates
{
    [self.representedObject willSimulatePhysics];
}

- (void)finalizeUpdates
{
    [self.representedObject didSimulatePhysics];
}

- (void)addContactedBody:(RZXPhysicsBody *)other
{
    [_contactedBodies addObject:other];
}

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
    GLKVector3 movement = GLKVector3MultiplyScalar(self.velocity, dt);
    [self adjustPosition:movement];
}

@end
