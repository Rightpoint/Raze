//
//  RZXNode+RZXAnimation.m
//  RazeScene
//
//  Created by Rob Visentin on 7/13/15.
//

#import <RazeCore/RZXBase.h>
#import <RazeCore/RZXTransform3D.h>
#import <RazeCore/NSValue+RZXExtensions.h>
#import <RazeAnimation/RZXBasicAnimation.h>
#import <RazeAnimation/CAAnimation+RZXExtensions.h>
#import <RazeScene/RZXNode+RZXAnimation.h>

@implementation RZXNode (RZXAnimation)

#pragma mark - Relative Animations

- (void)translateBy:(GLKVector3)translation withDuration:(NSTimeInterval)duration
{
    [self translateBy:translation withDuration:duration completion:nil];
}

- (void)translateBy:(GLKVector3)translation withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion
{
    [self translateBy:translation withDuration:duration delay:0.0 options:kNilOptions start:nil completion:completion];
}

- (void)translateBy:(GLKVector3)translation withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion
{
    RZXBasicAnimation *animation = [RZXBasicAnimation animationWithKeyPath:RZX_KP_SELF(transform.translation) options:options];
    animation.duration = duration;
    animation.byValue = [NSValue rzx_valueWithVec3:translation];
    animation.rzx_startBlock = start;
    animation.rzx_completionBlock = completion;

    [self addAnimation:animation forKey:nil];
}

- (void)scaleBy:(GLKVector3)scale withDuration:(NSTimeInterval)duration
{
    [self scaleBy:scale withDuration:duration completion:nil];
}

- (void)scaleBy:(GLKVector3)scale withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion
{
    [self scaleBy:scale withDuration:duration delay:0.0 options:kNilOptions start:nil completion:completion];
}

- (void)scaleBy:(GLKVector3)scale withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion
{
    RZXBasicAnimation *animation = [RZXBasicAnimation animationWithKeyPath:RZX_KP_SELF(transform.scale) options:options];
    animation.duration = duration;
    animation.byValue = [NSValue rzx_valueWithVec3:scale];
    animation.rzx_startBlock = start;
    animation.rzx_completionBlock = completion;

    [self addAnimation:animation forKey:nil];
}

- (void)rotateBy:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration
{
    [self rotateBy:rotation withDuration:duration completion:nil];
}

- (void)rotateBy:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion
{
    [self rotateBy:rotation withDuration:duration delay:0.0 options:kNilOptions start:nil completion:completion];
}

- (void)rotateBy:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion
{
    rotation = GLKQuaternionNormalize(rotation);

    RZXBasicAnimation *animation = [RZXBasicAnimation animationWithKeyPath:RZX_KP_SELF(transform.rotation) options:options];
    animation.duration = duration;
    animation.byValue = [NSValue rzx_valueWithQuaternion:rotation];
    animation.rzx_startBlock = start;
    animation.rzx_completionBlock = completion;

    [self addAnimation:animation forKey:nil];
}

#pragma mark - Absolute Animations

- (void)translateTo:(GLKVector3)translation withDuration:(NSTimeInterval)duration
{
    [self translateTo:translation withDuration:duration completion:nil];
}

- (void)translateTo:(GLKVector3)translation withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion
{
    [self translateTo:translation withDuration:duration delay:0.0 options:kNilOptions start:nil completion:completion];
}

- (void)translateTo:(GLKVector3)translation withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion
{
    RZXBasicAnimation *animation = [RZXBasicAnimation animationWithKeyPath:RZX_KP_SELF(transform.translation) options:options];
    animation.duration = duration;
    animation.toValue = [NSValue rzx_valueWithVec3:translation];
    animation.rzx_startBlock = start;
    animation.rzx_completionBlock = completion;

    [self addAnimation:animation forKey:nil];
}

- (void)scaleTo:(GLKVector3)scale withDuration:(NSTimeInterval)duration
{
    [self scaleTo:scale withDuration:duration completion:nil];
}

- (void)scaleTo:(GLKVector3)scale withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion
{
    [self scaleTo:scale withDuration:duration delay:0.0 options:kNilOptions start:nil completion:completion];
}

- (void)scaleTo:(GLKVector3)scale withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion
{
    RZXBasicAnimation *animation = [RZXBasicAnimation animationWithKeyPath:RZX_KP_SELF(transform.scale) options:options];
    animation.duration = duration;
    animation.toValue = [NSValue rzx_valueWithVec3:scale];
    animation.rzx_startBlock = start;
    animation.rzx_completionBlock = completion;

    [self addAnimation:animation forKey:nil];
}

- (void)rotateTo:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration
{
    [self rotateTo:rotation withDuration:duration completion:nil];
}

- (void)rotateTo:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration completion:(RZXAnimationCompletionBlock)completion
{
    [self rotateTo:rotation withDuration:duration delay:0.0 options:kNilOptions start:nil completion:completion];
}

- (void)rotateTo:(GLKQuaternion)rotation withDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(RZXAnimationOptions)options start:(RZXAnimationStartBlock)start completion:(RZXAnimationCompletionBlock)completion
{
    rotation = GLKQuaternionNormalize(rotation);

    RZXBasicAnimation *animation = [RZXBasicAnimation animationWithKeyPath:RZX_KP_SELF(transform.rotation) options:options];
    animation.duration = duration;
    animation.byValue = [NSValue rzx_valueWithQuaternion:rotation];
    animation.rzx_startBlock = start;
    animation.rzx_completionBlock = completion;

    [self addAnimation:animation forKey:nil];
}

@end
