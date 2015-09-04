//
//  RZXViewTexture.h
//
//  Created by Rob Visentin on 1/9/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RazeCore/RZXDynamicTexture.h>

/**
 *  Creates a dynamic texture from a UIView
 */
@interface RZXViewTexture : RZXDynamicTexture

+ (instancetype)textureWithSize:(CGSize)size;

- (void)updateWithView:(UIView *)view synchronous:(BOOL)synchronous;

@end
