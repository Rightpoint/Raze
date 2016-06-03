//
//  RZXNode+RZXAnimation.h
//  RazeScene
//
//  Created by Rob Visentin on 7/13/15.
//

#import <RazeScene/RZXNode.h>
#import <RazeAnimation/RZXAnimationBase.h>

// These keys are used to run absolute animations e.g. translateTo, scaleTo, rotateTo.
OBJC_EXTERN NSString* const kRZXTranslationAnimationKey;
OBJC_EXTERN NSString* const kRZXScaleAnimationKey;
OBJC_EXTERN NSString* const kRZXRotationAnimationKey;

/**
 *  Helpers for applying animations to RZXNodes
 */
@interface RZXNode (RZXAnimation)

#pragma mark - Relative Animations

- (void)translateBy:(GLKVector3)translation withDuration:(NSTimeInterval)duration;

- (void)translateBy:(GLKVector3)translation withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion;

- (void)translateBy:(GLKVector3)translation withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion;

- (void)scaleBy:(GLKVector3)scale withDuration:(NSTimeInterval)duration;

- (void)scaleBy:(GLKVector3)scale withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion;

- (void)scaleBy:(GLKVector3)scale withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion;

- (void)rotateBy:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration;

- (void)rotateBy:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion;

- (void)rotateBy:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion;

#pragma mark - Absolute Animations

- (void)translateTo:(GLKVector3)translation withDuration:(NSTimeInterval)duration;

- (void)translateTo:(GLKVector3)translation withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion;

- (void)translateTo:(GLKVector3)translation withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion;

- (void)scaleTo:(GLKVector3)scale withDuration:(NSTimeInterval)duration;

- (void)scaleTo:(GLKVector3)scale withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion;

- (void)scaleTo:(GLKVector3)scale withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion;

- (void)rotateTo:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration;

- (void)rotateTo:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion;

- (void)rotateTo:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion;

@end
