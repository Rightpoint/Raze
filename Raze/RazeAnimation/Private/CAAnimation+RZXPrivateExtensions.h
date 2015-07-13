//
//  CAAnimation+RZXPrivateExtensions.h
//  RazeAnimation
//
//  Created by Rob Visentin on 6/24/15.
//

#import <RazeAnimation/CAAnimation+RZXExtensions.h>

@class RZXAnimationState;
@class RZXInterpolator;

@interface CAAnimation (RZXPrivateExtensions)

@property (strong, nonatomic, readonly) RZXAnimationState *rzx_state;

- (float)rzx_interpolationFactorForTime:(CFTimeInterval)currentTime;

- (id)rzx_interpolateAtTime:(CFTimeInterval)time withInterpolator:(RZXInterpolator *)interpolator currentValue:(id)currentValue;

@end
