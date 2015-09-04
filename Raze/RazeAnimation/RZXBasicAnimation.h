//
//  RZXBasicAnimation.h
//  RazeAnimation
//
//  Created by Rob Visentin on 7/13/15.
//

#import <RazeAnimation/RZXAnimationBase.h>

/**
 *  Uses the structure of Core Animation's basic animation to generate animations for Raze.
 */
@interface RZXBasicAnimation : CABasicAnimation

+ (instancetype)animationWithKeyPath:(NSString *)path options:(RZXAnimationOptions)options;

@end
