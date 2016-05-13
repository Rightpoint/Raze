//
//  RZXColor+RZXExtensions.m
//  RazeCore
//
//  Created by Rob Visentin on 5/13/16.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXColor+RZXExtensions.h>

@implementation RZXColor (RZXExtensions)

- (GLKVector4)rzx_components
{
    CGFloat r, g, b, a;

    if ( [self getRed:&r green: &g blue: &b alpha: &a] ) {
        // no-op
    }
    else if ( [self getWhite:&r alpha:&a] ) {
         g = r;
         b = r;
    }
    else {
        r = g = b = a = 0.0f;
    }

    return GLKVector4Make(r, g, b, a);
}

@end
