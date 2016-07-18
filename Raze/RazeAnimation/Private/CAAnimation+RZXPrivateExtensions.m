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

- (void)rzx_notifyStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( [self.delegate respondsToSelector:@selector(animationDidStart:)] ) {
            [self.delegate animationDidStart:self];
        }

        if ( self.rzx_startBlock != nil ) {
            self.rzx_startBlock(self);
        }
    });
}

- (void)rzx_notifyStop:(BOOL)finished
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( [self.delegate respondsToSelector:@selector(animationDidStop:finished:)] ) {
            [self.delegate animationDidStop:self finished:finished];
        }

        if ( self.rzx_completionBlock != nil ) {
            self.rzx_completionBlock(self, finished);
        }
    });
}

@end
