//
//  CAAnimation+RZXExtensions.h
//  RazeAnimation
//
//  Created by Rob Visentin on 7/10/15.
//

#import <RazeCore/RZXUpdateable.h>
#import <RazeAnimation/RZXAnimationBase.h>

@interface CAAnimation (RZXExtensions) <RZXUpdateable>

@property (copy, nonatomic, setter=rzx_setStartBlock:) RZXAnimationStartBlock rzx_startBlock;

@property (copy, nonatomic, setter=rzx_setCompletionBlock:) RZXAnimationCompletionBlock rzx_completionBlock;

@property (assign, nonatomic, readonly, getter=rzx_isFinished) BOOL rzx_finished;

- (void)rzx_applyToObject:(id)object;
- (void)rzx_interrupt;

@end

@interface CABasicAnimation (RZXOptions)

+ (instancetype)rzx_animationWithKeyPath:(NSString *)path options:(RZXAnimationOptions)options;

@end
