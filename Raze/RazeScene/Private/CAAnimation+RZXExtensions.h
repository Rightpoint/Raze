//
//  CAAnimation+RZXPrivateExtensions.h
//  RazeScene
//
//  Created by Rob Visentin on 6/24/15.
//

#import <QuartzCore/CAAnimation.h>
#import <RazeCore/RZXUpdateable.h>

@class RZXAnimationState;

@interface CAAnimation (RZXPrivateExtensions) <RZXUpdateable>

@property (assign, nonatomic, readonly, getter=isFinished) BOOL finished;

- (void)rzx_applyToObject:(NSObject *)object;
- (void)rzx_interrupt;

@end
