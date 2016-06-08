//
//  RZXHullCollider.m
//  RazePhysics
//
//  Created by Rob Visentin on 6/8/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXHullCollider.h>
#import <RazePhysics/RZXCollider_Private.h>
#import <RazePhysics/RZXGJK.h>

#import <RazePhysics/RZXSphereCollider.h>
#import <RazePhysics/RZXBoxCollider.h>

@implementation RZXHullCollider

#pragma mark - private

- (BOOL)pointInside:(GLKVector3)point
{
    // TODO: implement point in poly
    return NO;
}

- (RZXContact *)generateContact:(RZXCollider *)other
{
    // TODO: call through to GJK
    return nil;
}

@end
