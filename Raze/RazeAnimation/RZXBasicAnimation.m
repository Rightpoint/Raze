//
//  RZXBasicAnimation.m
//  RazeAnimation
//
//  Created by Rob Visentin on 7/13/15.
//
//

#import <QuartzCore/CAMediaTimingFunction.h>
#import <RazeAnimation/RZXBasicAnimation.h>

@implementation RZXBasicAnimation

+ (instancetype)animationWithKeyPath:(NSString *)path options:(RZXAnimationOptions)options
{
    RZXBasicAnimation *animation = [self animationWithKeyPath:path];

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
