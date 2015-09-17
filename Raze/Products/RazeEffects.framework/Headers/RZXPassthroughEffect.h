//
//  RZXPassthroughEffect.h
//  Raze
//
//  Created by Rob Visentin on 6/19/15.
//
//

#import <RazeEffects/RZXEffect.h>

OBJC_EXTERN NSString* const kRZXEffectPassthroughVSH2D;
OBJC_EXTERN NSString* const kRZXEffectPassthroughVSH3D;
OBJC_EXTERN NSString* const kRZXEffectPassthroughFSH;

/**
 *  Generic effects applying the minimum values needed for a simple 2D or 3D effect
 */
@interface RZXPassthroughEffect : RZXEffect

+ (instancetype)effect2D;
+ (instancetype)effect3D;

@end
