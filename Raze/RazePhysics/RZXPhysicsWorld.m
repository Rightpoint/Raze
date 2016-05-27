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

- (NSSet *)computeCollisions
{
    NSMutableSet *collisions = [NSMutableSet set];

    for ( RZXPhysicsBody *first in _bodies ) {
        if ( !first.collider.active ) {
            continue;
        }

        for ( RZXPhysicsBody *second in _bodies ) {
            if ( first == second || !second.collider.active ) {
                continue;
            }

            RZXCollision *collision = [[RZXCollision alloc] init];
            collision.first = first;
            collision.second = second;

            if ( ![collisions containsObject:collision] && [first.collider collidesWith:second.collider] ) {
                [collisions addObject:collision];
            }
        }
    }

    return [collisions copy];
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    // TODO: update physics state
}

@end

#pragma mark - RZXCollision

@implementation RZXCollision

- (BOOL)isEqual:(id)object
{
    BOOL equal = NO;

    if ( object == self ) {
        equal = YES;
    }
    else if ( [object isKindOfClass:[self class]] ) {
        RZXCollision *other = (RZXCollision *)object;
        equal = (_first == other.first && _second == other.second) ||
                (_first == other.second && _second == other.first);
    }

    return equal;
}

- (NSUInteger)hash
{
    return (_first.hash ^ _second.hash);
}

@end
