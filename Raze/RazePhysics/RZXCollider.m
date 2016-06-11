//
//  RZXCollider.m
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCollider.h>
#import <RazePhysics/RZXCollider_Private.h>

@implementation RZXCollider

- (instancetype)init
{
    if ( (self = [super init]) ) {
        _active = YES;
    }

    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    RZXCollider *copy = [[[self class] alloc] init];
    copy->_active = _active;

    return copy;
}

#pragma mark - private

- (RZXTransform3D *)worldTransform
{
    return self.body.representedObject.worldTransform;
}

- (RZXBox)boundingBox
{
    [NSException raise:NSGenericException format:@"%@ is an abstract class. Please instantiate a concrete subclass instead", [self class]];
    return (RZXBox){};
}

- (RZXSphere)boundingSphere
{
    [NSException raise:NSGenericException format:@"%@ is an abstract class. Please instantiate a concrete subclass instead", [self class]];
    return (RZXSphere){};
}

- (BOOL)pointInside:(GLKVector3)point
{
    [NSException raise:NSGenericException format:@"%@ is an abstract class. Please instantiate a concrete subclass instead", [self class]];
    return NO;
}

- (RZXContact *)generateContact:(RZXCollider *)other
{
    [NSException raise:NSGenericException format:@"%@ is an abstract class. Please instantiate a concrete subclass instead", [self class]];
    return nil;
}

@end
