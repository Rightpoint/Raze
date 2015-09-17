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

    state.currentTime += dt;
    state.repetition += dt / self.duration;
}

@end
