//
//  RZXViewTexture.h
//
//  Created by Rob Visentin on 1/9/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RazeCore/RZXDynamicTexture.h>

/**
 *  Creates a dynamic texture from a UIView.
 */
@interface RZXViewTexture : RZXDynamicTexture

+ (instancetype)textureWithSize:(CGSize)size;

/**
 *  Renders the contents of the given view into the receiver's texture buffer.
 *
 *  @param view        The view to render to the receiver's texture buffer.
 *  @param synchronous Whether the rendering should be performed synchronously.
 *
 *  @note This method uses drawViewHierarchyInRect to render the view.
 *  Although not documented, this method is NOT threadsafe (specifically when layers are added or removed during view rendering).
 *  Updating the texture asynchronously is significantly more performant, 
 *  but if there is question whether or not async will be safe, then pass YES for the synchronous parameter.
 */
- (void)updateWithView:(UIView *)view synchronous:(BOOL)synchronous;

@end
