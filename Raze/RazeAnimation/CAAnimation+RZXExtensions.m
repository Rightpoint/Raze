//
//  CAAnimation+RZXExtensions.m
//  RazeAnimation
//
//  Created by Rob Visentin on 7/10/15.
//

#import <RazeAnimation/CAAnimation+RZXExtensions.h>
#import <RazeAnimation/CAAnimation+RZXPrivateExtensions.h>
#import <RazeAnimation/RZXAnimationState.h>

static NSString* const kRZXAnimationStartBlockKey = @"_RZXAnimationStartBlock";
static NSString* const kRZXAnimationCompletionBlockKey = @"_RZXAnimationCompletionBlock";

@implementation CAAnimation (RZXExtensions)

- (RZXAnimationStartBlock)rzx_startBlock
{
    return [self valueForKey:kRZXAnimationStartBlockKey];
}

- (void)rzx_setStartBlock:(RZXAnimationStartBlock)rzx_startBlock
{
    [self setValue:rzx_startBlock forKey:kRZXAnimationStartBlockKey];
}

- (RZXAnimationCompletionBlock)rzx_completionBlock
{
    return [self valueForKey:kRZXAnimationCompletionBlockKey];
}

- (void)rzx_setCompletionBlock:(RZXAnimationCompletionBlock)rzx_completion
{
    [self setValue:[rzx_completion copy] forKey:kRZXAnimationCompletionBlockKey];
}

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

    if ( state.isStarted && !state.isFinished ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( [self.delegate respondsToSelector:@selector(animationDidStop:finished:)] ) {
                [self.delegate animationDidStop:self finished:NO];
            }

            if ( self.rzx_completionBlock != nil ) {
                self.rzx_completionBlock(self, NO);
            }
        });
    }
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    RZXAnimationState *state = self.rzx_state;
    dt = dt * self.speed;

    state.currentTime += dt;

    if ( self.duration != 0.0 ) {
        state.repetition += dt / self.duration;
    }
    else {
        state.repetition = 0.0f;
    }
}

@end

@implementation CABasicAnimation (RZXOptions)

+ (instancetype)rzx_animationWithKeyPath:(NSString *)path options:(RZXAnimationOptions)options
{
    CABasicAnimation *animation = [self animationWithKeyPath:path];

    if ( options & kRZXAnimationOptionRepeat ) {
        animation.repeatCount = HUGE_VALF;
    }

    if ( options & kRZXAnimationOptionAutoReverse ) {
        animation.autoreverses = YES;
    }

    if ( options & kRZXAnimationOptionCurveEaseIn ) {
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    }
    else if ( options & kRZXAnimationOptionCurveEaseOut ) {
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    }
    else if ( options & kRZXAnimationOptionCurveEaseInOut ) {
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    }

    return animation;
}

@end
