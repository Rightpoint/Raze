//
//  RZXPhysicsWorld.m
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//


#import <RazePhysics/RZXPhysicsWorld.h>
#import <RazePhysics/RZXCollider_Private.h>
#import <RazePhysics/RZXPhysicsBody_Private.h>

@implementation RZXPhysicsWorld {
    NSMutableSet *_bodies;
}

- (instancetype)init
{
    if ( (self = [super init]) ) {
        _bodies = [NSMutableSet set];
    }

    return self;
}

- (void)addBody:(RZXPhysicsBody *)body
{
    if ( body != nil ) {
        [_bodies addObject:body];
        body.world = self;
    }
}

- (void)removeBody:(RZXPhysicsBody *)body
{
    if ( body != nil ) {
        [_bodies removeObject:body];

        if ( body.world == self ) {
            body.world = nil;
        }
    }
}

- (RZXPhysicsBody *)bodyAtPoint:(GLKVector3)point
{
    __block RZXPhysicsBody *body = nil;

    [self enumerateBodiesAtPoint:point withBlock:^(RZXPhysicsBody *b, BOOL *stop) {
        body = b;
        *stop = YES;
    }];

    return body;
}

- (void)enumerateBodiesAtPoint:(GLKVector3)point withBlock:(RZXPhysicsBodyEnumeration)block
{
    [self enumerateBodiesWithBlock:^(RZXPhysicsBody *body, BOOL *stop) {
        if ( [body.collider pointInside:point] ) {
            block(body, stop);
        }
    }];
}

- (void)enumerateBodiesWithBlock:(RZXPhysicsBodyEnumeration)block
{
    [_bodies enumerateObjectsUsingBlock:block];
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    NSArray *bodies = _bodies.allObjects;

    GLKVector3 gravity = GLKVector3MultiplyScalar(self.gravity, dt);

    for ( RZXPhysicsBody *body in bodies ) {
        if ( body.isDynamic && body.isAffectedByGravity && body.mass > 0.0 ) {
            [body applyImpulse:gravity];
        }
    }

    [self resolveContactsForBodies:bodies];

    for ( RZXPhysicsBody *body in bodies ) {
        [body rzx_update:dt];
    }
}

#pragma mark - private

- (void)resolveContactsForBodies:(NSArray *)bodies
{
    // iterate all pairs of bodies
    for ( NSUInteger i = 0; i< bodies.count; ++i ) {
        for ( NSUInteger j = i + 1; j < bodies.count; ++j ) {
            RZXPhysicsBody *first = bodies[i];
            RZXPhysicsBody *second = bodies[j];

            RZXContact *contact = [first generateContact:second];

            if ( contact != nil ) {
                [self resolveContact:contact];
            }
        }
    }
}

- (void)resolveContact:(RZXContact *)contact
{
    // TODO: resolve the contact
}

@end
