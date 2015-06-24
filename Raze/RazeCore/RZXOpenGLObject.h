//
//  RZXOpenGLObject.h
//
//  Created by Rob Visentin on 1/14/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RZXOpenGLObject <NSObject>

- (void)rzx_setupGL;
- (void)rzx_bindGL;
- (void)rzx_teardownGL;

@end
