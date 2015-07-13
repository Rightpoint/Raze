//
//  CAAnimation+RZXExtensions.h
//  RazeAnimation
//
//  Created by Rob Visentin on 7/10/15.
//

#import <QuartzCore/CAAnimation.h>
#import <RazeCore/RZXUpdateable.h>

@interface CAAnimation (RZXExtensions) <RZXUpdateable>

@property (assign, nonatomic, readonly, getter=rzx_isFinished) BOOL rzx_finished;

- (void)rzx_applyToObject:(id)object;
- (void)rzx_interrupt;

@end
