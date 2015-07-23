//
//  RZXConvolutionEffect.h
//  RazeEffects
//
//  Created by Rob Visentin on 7/23/15.
//

#import <RazeEffects/RZXEffect.h>

OBJC_EXTERN GLKMatrix3 const kRZXConvoultionKernelIdentity;
OBJC_EXTERN NSString* const kRZXEffectConvolutionVSH;

@interface RZXConvolutionEffect : RZXEffect

@property (assign, nonatomic) GLKMatrix3 kernel;

// Post processing src e.g. @"rgb = normalize(rgb);"
+ (instancetype)effectWithKernel:(GLKMatrix3)kernel postProcessing:(NSString *)postProcessingSrc;

@end
