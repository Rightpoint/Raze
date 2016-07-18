//
//  CAAnimation+RZXExtensions.h
//  RazeAnimation
//
//  Created by Rob Visentin on 7/10/15.
//

#import <RazeCore/RZXUpdateable.h>
#import <RazeAnimation/RZXAnimationBase.h>

typedef void (^RZXAnimationBlock)(id object, float normalizedTime);

@interface CAAnimation (RZXExtensions) <RZXUpdateable>

@property (copy, nonatomic, setter=rzx_setStartBlock:) RZXAnimationStartBlock rzx_startBlock;

@property (copy, nonatomic, setter=rzx_setCompletionBlock:) RZXAnimationCompletionBlock rzx_completionBlock;

@property (assign, nonatomic, readonly, getter=rzx_isFinished) BOOL rzx_finished;

+ (instancetype)rzx_animationWithBlock:(RZXAnimationBlock)block;

- (void)rzx_applyToObject:(id)object;
- (void)rzx_interrupt;

@end

@interface CABasicAnimation (RZXOptions)

+ (instancetype)rzx_animationWithKeyPath:(NSString *)path options:(RZXAnimationOptions)options;

@end

@interface CABasicAnimation (RZXUnavailable)

+ (instancetype)rzx_animationWithBlock:(RZXAnimationBlock)block UNAVAILABLE_ATTRIBUTE;

@end
