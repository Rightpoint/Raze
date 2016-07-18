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

- (void)rzx_notifyStart;
- (void)rzx_notifyStop:(BOOL)finished;

@end
