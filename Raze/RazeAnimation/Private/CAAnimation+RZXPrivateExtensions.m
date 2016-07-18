//
//  CAAnimation+RZXPrivateExtensions.m
//  RazeAnimation
//
//  Created by Rob Visentin on 6/24/15.
//

#import <objc/runtime.h>
#import <RazeAnimation/CAAnimation+RZXPrivateExtensions.h>
#import <RazeAnimation/CAMediaTimingFunction+RZXExtensions.h>
#import <RazeAnimation/RZXAnimationState.h>

#pragma mark - CAAnimation

@implementation CAAnimation (RZXPrivateExtensions)

- (RZXAnimationState *)rzx_state
{
    // NOTE: this value is NOT copied with -copy. Therefore all copies have fresh state.
    RZXAnimationState *state = objc_getAssociatedObject(self, _cmd);

    if ( state == nil ) {
        state = [[RZXAnimationState alloc] init];
        objc_setAssociatedObject(self, _cmd, state, OBJC_ASSOCIATION_RETAIN);
    }

    return state;
}

- (float)rzx_interpolationFactorForTime:(CFTimeInterval)currentTime
{
    float t = (self.duration != 0.0) ? (currentTime / self.duration) : 1.0f;
    CAMediaTimingFunction *function = self.timingFunction;

    // default to linear timing if no function is supplied
    return function ? [function rzx_solveForNormalizedTime:t] : t;
}

@end
