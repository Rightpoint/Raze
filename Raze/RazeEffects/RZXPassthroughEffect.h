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

@interface RZXPassthroughEffect : RZXEffect

+ (instancetype)effect2D;
+ (instancetype)effect3D;

@end
