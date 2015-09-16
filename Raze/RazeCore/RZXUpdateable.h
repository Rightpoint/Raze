//
//  RZXUpdateable.h
//
//  Created by Rob Visentin on 3/6/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 Protocol for any object that will be updated typically as part of a update/rendering 
 */
@protocol RZXUpdateable <NSObject>

/**
 *  Update method to typically be called per frame
 *
 *  @param dt time elapsed since last update
 */
- (void)rzx_update:(NSTimeInterval)dt;

@end
