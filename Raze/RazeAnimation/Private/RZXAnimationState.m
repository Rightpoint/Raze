//
//  RZXAnimationState.m
//  RazeAnimation
//
//  Created by Rob Visentin on 7/10/15.
//

#import <QuartzCore/CAAnimation.h>
#import <RazeAnimation/RZXAnimationState.h>

@implementation RZXAnimationState

- (BOOL)updateWithAnimation:(CAAnimation *)animation
{
    BOOL reset = NO;

    NSTimeInterval duration = animation.duration;
    float repeatCount = animation.repeatCount;
    CFTimeInterval repeatDuration = animation.repeatDuration;

    if ( self.currentTime > 0.0 && !self.isStarted ) {
        self.started = YES;
        reset = YES;
    }

    if ( repeatCount > 0.0f && self.repetition >= repeatCount + 1 ) {
        CFTimeInterval remainingTime = fmod(repeatCount * duration, duration);

        self.currentTime = remainingTime > 0.0 ? remainingTime : duration;
        self.repetition = repeatCount;
        self.finished = YES;
    }
    else if ( repeatDuration > 0.0 && self.repetition * duration >= repeatDuration ) {
        CFTimeInterval remainingTime = fmod(repeatDuration, duration);

        self.currentTime = remainingTime > 0.0 ? remainingTime : duration;
        self.repetition = repeatDuration / duration;
        self.finished = YES;
    }
    else if ( self.currentTime >= duration ) {
        if ( repeatCount > 0.0f || repeatDuration > 0.0 ) {
            self.currentTime -= duration;
            reset = YES;
        }
        else {
            self.currentTime = duration;
            self.finished = YES;
        }
    }
    
    return reset;
}

@end