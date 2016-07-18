//
//  CAMediaTimingFunction+RZXExtensions.h
//  RazeAnimation
//
//  Created by Rob Visentin on 7/17/16.
//

#import <RazeAnimation/RZXAnimationBase.h>

@interface CAMediaTimingFunction (RZXExtensions)

/**
 *  A public implementation of the private _solveForInput: method.
 *
 *  @param t    A value in [0, 1] representing percentage complete.
 *
 *  @return The solution on the curve for the given normalized time.
 */
- (float)rzx_solveForNormalizedTime:(float)t;

@end
