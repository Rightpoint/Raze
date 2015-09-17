//
//  RZXRenderable.h
//
//  Created by Rob Visentin on 1/14/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Protocol for any object to be renderered. Requires - (void)rzx_render
 */
@protocol RZXRenderable <NSObject>

/**
 *  Render the object
 */
- (void)rzx_render;

@end
