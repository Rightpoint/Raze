//
//  RZXPhysicsWorld.m
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//


#import <RazePhysics/RZXPhysicsWorld.h>
#import <RazePhysics/RZXCollider_Private.h>

@implementation RZXPhysicsWorld {
    NSMutableSet *_colliders;
}

- (instancetype)init
{
    if ( (self = [super init]) ) {
        _colliders = [NSMutableSet set];
    }

    return self;
}

- (void)addCollider:(RZXCollider *)collider
{
    if ( collider != nil ) {
        [_colliders addObject:collider];
        collider.world = self;
    }
}

- (void)removeCollider:(RZXCollider *)collider
{
    if ( collider != nil ) {
        [_colliders removeObject:collider];

        if ( collider.world == self ) {
            collider.world = nil;
        }
    }
}

- (RZXCollider *)colliderAtPoint:(GLKVector3)point
{
    __block RZXCollider *collider = nil;

    [self enumerateCollidersAtPoint:point withBlock:^(RZXCollider *c, BOOL *stop) {
        collider = c;
        *stop = YES;
    }];

    return collider;
}

- (void)enumerateCollidersAtPoint:(GLKVector3)point withBlock:(RZXColliderEnumerationBlock)block
{
    [self enumerateCollidersWithBlock:^(RZXCollider *collider, BOOL *stop) {
        if ( [collider pointInside:point] ) {
            block(collider, stop);
        }
    }];
}

- (void)enumerateCollidersWithBlock:(void (^)(RZXCollider *, BOOL *))block
{
    [_colliders enumerateObjectsUsingBlock:block];
}

- (NSSet *)computeCollisions
{
    NSMutableSet *collisions = [NSMutableSet set];

    for ( RZXCollider *first in _colliders ) {
        if ( !first.active ) {
            continue;
        }

        for ( RZXCollider *second in _colliders ) {
            if ( first == second || !second.active ) {
                continue;
            }

            RZXCollision *collision = [[RZXCollision alloc] init];
            collision.first = first;
            collision.second = second;

            if ( ![collisions containsObject:collision] && [first collidesWith:second] ) {
                [collisions addObject:collision];
            }
        }
    }

    return [collisions copy];
}

@end

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
