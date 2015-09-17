//
//  RZXImageFilter.h
//  RazeEffects
//
//  Created by Rob Visentin on 7/23/15.
//

#import <CoreGraphics/CoreGraphics.h>

@class RZXEffect;

/**
 *  Applies an effect to an image
 */
@interface RZXImageFilter : NSObject

@property (assign, nonatomic) CGImageRef sourceImage;
@property (strong, nonatomic) RZXEffect *effect;

- (instancetype)initWithSourceImage:(CGImageRef)sourceImage effect:(RZXEffect *)effect;

- (CGImageRef)outputImage NS_RETURNS_INNER_POINTER CF_RETURNS_NOT_RETAINED;

@end
