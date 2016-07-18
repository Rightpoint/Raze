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

    CFTimeInterval duration = animation.duration;
    float repeatCount = animation.repeatCount;
    CFTimeInterval repeatDuration = animation.repeatDuration;
    CFTimeInterval beginTime = animation.beginTime;

    if ( _currentTime > beginTime && !_started ) {
        _currentTime -= beginTime;
        _repetition = duration > 0.0 ? _currentTime / duration : 0.0;
        _started = YES;
        reset = YES;
    }

    if ( _started ) {
        if ( repeatCount > 0.0f && _repetition >= repeatCount + 1 ) {
            CFTimeInterval remainingTime = fmod(repeatCount * duration, duration);

            _currentTime = remainingTime > 0.0 ? remainingTime : duration;
            _repetition = repeatCount;
            _finished = YES;
        }
        else if ( repeatDuration > 0.0 && _repetition * duration >= repeatDuration ) {
            CFTimeInterval remainingTime = fmod(repeatDuration, duration);

            _currentTime = remainingTime > 0.0 ? remainingTime : duration;
            _repetition = repeatDuration / duration;
            _finished = YES;
        }
        else if ( _currentTime >= duration ) {
            if ( repeatCount > 0.0f || repeatDuration > 0.0 ) {
                _currentTime -= duration;
                reset = YES;
            }
            else {
                _currentTime = duration;
                _finished = YES;
            }
        }
    }
    
    return reset;
}

@end