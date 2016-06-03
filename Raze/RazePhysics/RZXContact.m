//
//  RZXContact.m
//  RazePhysics
//
//  Created by Rob Visentin on 6/2/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXContact.h>
#import <RazePhysics/RZXPhysicsBody.h>

@implementation RZXContact

- (BOOL)isEqual:(id)object
{
    BOOL equal = NO;

    if ( object == self ) {
        equal = YES;
    }
    else if ( [object isKindOfClass:[self class]] ) {
        RZXContact *other = (RZXContact *)object;
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
