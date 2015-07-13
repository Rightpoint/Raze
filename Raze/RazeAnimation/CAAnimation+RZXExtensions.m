//
//  CAAnimation+RZXExtensions.m
//  RazeAnimation
//
//  Created by Rob Visentin on 7/10/15.
//

#import <RazeAnimation/CAAnimation+RZXExtensions.h>
#import <RazeAnimation/CAAnimation+RZXPrivateExtensions.h>
#import <RazeAnimation/RZXAnimationState.h>

@implementation CAAnimation (RZXExtensions)

- (BOOL)rzx_isFinished
{
    return self.rzx_state.isFinished;
}

- (CFTimeInterval)rzx_currentTime
{
    return self.rzx_state.currentTime;
}

- (void)rzx_applyToObject:(id)object
{
    // base class is a no-op. subclasses override
    self.rzx_state.finished = YES;
}

- (void)rzx_interrupt
{
    RZXAnimationState *state = [self rzx_state];

    if ( state.isStarted && !state.isFinished && [self.delegate respondsToSelector:@selector(animationDidStop:finished:)] ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate animationDidStop:self finished:NO];
        });
    }
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    RZXAnimationState *state = self.rzx_state;

    state.currentTime += dt;
    state.repetition += dt / self.duration;
}

@end
