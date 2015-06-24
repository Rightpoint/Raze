//
//  RZXUpdateable.h
//
//  Created by Rob Visentin on 3/6/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RZXUpdateable <NSObject>

#warning Prefix with rzx_
- (void)update:(NSTimeInterval)dt;

@end
