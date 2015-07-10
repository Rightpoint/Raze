//
//  RZXAnimationState.h
//  RazeAnimation
//
//  Created by Rob Visentin on 7/10/15.
//

#import <Foundation/Foundation.h>

@class CAAnimation;

@interface RZXAnimationState : NSObject

@property (assign, nonatomic, getter=isStarted) BOOL started;
@property (assign, nonatomic, getter=isFinished) BOOL finished;

@property (assign, nonatomic) CFTimeInterval currentTime;
@property (assign, nonatomic) float repetition;

// if animation is absolute, this is the initial value of the animated property
@property (strong, nonatomic) id initialValue;

// if animation is absolute, this is the target value of the animated property
@property (strong, nonatomic) id targetValue;

// the interpolated value applied so far
@property (strong, nonatomic) id appliedValue;

- (BOOL)updateWithAnimation:(CAAnimation *)animation;

@end