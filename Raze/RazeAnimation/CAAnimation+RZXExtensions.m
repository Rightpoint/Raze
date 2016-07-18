//
//  CAAnimation+RZXExtensions.m
//  RazeAnimation
//
//  Created by Rob Visentin on 7/10/15.
//

#import <objc/runtime.h>
#import <RazeAnimation/CAAnimation+RZXExtensions.h>
#import <RazeAnimation/CAAnimation+RZXPrivateExtensions.h>
#import <RazeAnimation/RZXAnimatable.h>
#import <RazeAnimation/RZXAnimationState.h>
#import <RazeAnimation/RZXInterpolator.h>

static NSString* const kRZXStartBlockKey = @"_RZXStartBlock";
static NSString* const kRZXCompletionBlockKey = @"_RZXCompletionBlock";
static NSString * const kRZXAnimationBlockKey = @"_RZXAnimationBlock";

#pragma mark - NSObject+RZXAnimationExtensions

@interface NSObject (RZXAnimationExtensions)

+ (RZXInterpolator *)rzx_cachedInterpolatorForKey:(NSString *)key;

@end

@implementation CAAnimation (RZXExtensions)

+ (instancetype)rzx_animationWithBlock:(RZXAnimationBlock)block
{
    CAAnimation *animation = [self animation];
    [animation setValue:block forKey:kRZXAnimationBlockKey];

    return animation;
}

- (RZXAnimationStartBlock)rzx_startBlock
{
    return [self valueForKey:kRZXStartBlockKey];
}

- (void)rzx_setStartBlock:(RZXAnimationStartBlock)rzx_startBlock
{
    [self setValue:rzx_startBlock forKey:kRZXStartBlockKey];
}

- (RZXAnimationCompletionBlock)rzx_completionBlock
{
    return [self valueForKey:kRZXCompletionBlockKey];
}

- (void)rzx_setCompletionBlock:(RZXAnimationCompletionBlock)rzx_completion
{
    [self setValue:[rzx_completion copy] forKey:kRZXCompletionBlockKey];
}

- (BOOL)rzx_isFinished
{
    return self.rzx_state.isFinished;
}

- (CFTimeInterval)rzx_currentTime
{
    return self.rzx_state.currentTime;
}

- (void)rzx_applyToObject:(id)object
{
    if ( self.rzx_isFinished ) {
        return;
    }

    RZXAnimationState *state = [self rzx_state];
    BOOL previouslyStarted = state.isStarted;

    RZXAnimationBlock animationBlock = [self valueForKey:kRZXAnimationBlockKey];

    if ( [state updateWithAnimation:self] && animationBlock != nil) {
        animationBlock(object, 0.0f);
    }

    if ( state.isStarted && animationBlock != nil) {
        animationBlock(object, [self rzx_interpolationFactorForTime:state.currentTime]);
    }

    if ( !previouslyStarted && state.isStarted ) {
        [self rzx_notifyStart];
    }

    if ( state.isStarted && state.isFinished ) {
        [self rzx_notifyStop:YES];
    }
}

- (void)rzx_interrupt
{
    RZXAnimationState *state = [self rzx_state];

    if ( state.isStarted && !state.isFinished ) {
        [self rzx_notifyStop:NO];
    }
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    RZXAnimationState *state = self.rzx_state;
    dt = dt * self.speed;

    state.currentTime += dt;

    if ( state.isStarted && self.duration != 0.0 ) {
        state.repetition += dt / self.duration;
    }
    else {
        state.repetition = 0.0f;
    }
}

@end

#pragma mark - CABasicAnimation+RZXExtensions

@implementation CABasicAnimation (RZXExtensions)

- (void)rzx_applyToObject:(id)object
{
    if ( self.rzx_isFinished ) {
        return;
    }

    id animatedObject = [object valueForKeyPath:[self.keyPath stringByDeletingPathExtension]];
    NSString *animatedKey = [self.keyPath pathExtension];
    RZXInterpolator *interpolator = [[animatedObject class] rzx_cachedInterpolatorForKey:animatedKey];

    RZXAnimationState *state = [self rzx_state];
    BOOL previouslyStarted = state.isStarted;

    id currentValue = [animatedObject valueForKey:animatedKey];

    if ( [state updateWithAnimation:self] && interpolator != nil ) {
        [self rzx_seedInitialAndTargetValuesForState:state withInterpolator:interpolator currentValue:currentValue];
    }

    if ( state.isStarted && interpolator != nil ) {
        id interpolatedValue = [self rzx_interpolateAtTime:state.currentTime withInterpolator:interpolator currentValue:currentValue];

        [animatedObject setValue:interpolatedValue forKey:animatedKey];
    }

    if ( !previouslyStarted && state.isStarted ) {
        [self rzx_notifyStart];
    }

    if ( state.isStarted && state.isFinished ) {
        [self rzx_notifyStop:YES];
    }
}

- (id)rzx_interpolateAtTime:(CFTimeInterval)time withInterpolator:(RZXInterpolator *)interpolator currentValue:(id)currentValue
{
    id value = nil;

    RZXAnimationState *state = [self rzx_state];

    float t = [self rzx_interpolationFactorForTime:time];

    if ( state.initialValue != nil && state.targetValue != nil ) {
        value = [interpolator interpolatedValueFrom:state.initialValue to:state.targetValue t:t];

        state.appliedValue = value;
    }
    else if ( self.byValue != nil ) {
        id interpolatedValue = [interpolator interpolatedValueFrom:nil to:self.byValue t:t];
        id addedValue = [interpolator addValue:[interpolator invertValue:state.appliedValue] toValue:interpolatedValue];
        value = [interpolator addValue:addedValue toValue:currentValue];

        state.appliedValue = interpolatedValue;
    }

    return value;
}

- (void)rzx_seedInitialAndTargetValuesForState:(RZXAnimationState *)state withInterpolator:(RZXInterpolator *)interpolator currentValue:(id)currentValue
{
    if ( self.fromValue != nil ) {
        state.initialValue = self.fromValue;

        if ( self.toValue != nil ) {
            state.targetValue = self.toValue;
        }
        else if ( self.byValue != nil ) {
            state.targetValue = [interpolator addValue:self.byValue toValue:self.fromValue];
        }
        else {
            state.targetValue = currentValue;
        }
    }
    else if ( self.toValue != nil ) {
        state.targetValue = self.toValue;

        if ( self.fromValue != nil ) {
            state.initialValue = self.fromValue;
        }
        else if ( self.byValue != nil ) {
            state.initialValue = [interpolator addValue:[interpolator invertValue:self.byValue] toValue:self.toValue];
        }
        else {
            state.initialValue = currentValue;
        }
    }
    
    state.appliedValue = nil;
}

@end

#pragma mark - CABasicAnimation+RZXOptions

@implementation CABasicAnimation (RZXOptions)

+ (instancetype)rzx_animationWithKeyPath:(NSString *)path options:(RZXAnimationOptions)options
{
    CABasicAnimation *animation = [self animationWithKeyPath:path];

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

#pragma mark - NSObject+RZXAnimationExtensions implementation

@implementation NSObject (RZXAnimationExtensions)

+ (RZXInterpolator *)rzx_cachedInterpolatorForKey:(NSString *)key
{
    NSMutableDictionary *functionCache = objc_getAssociatedObject(self, _cmd);

    if ( functionCache == nil ) {
        functionCache = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, functionCache, OBJC_ASSOCIATION_RETAIN);
    }

    RZXInterpolator *cachedFunction = functionCache[key];

    if ( cachedFunction == nil ) {
        if ( [self respondsToSelector:@selector(rzx_interpolatorForKey:)] ) {
            cachedFunction = [(id<RZXAnimatable>)self rzx_interpolatorForKey:key];

            functionCache[key] = cachedFunction ?: [NSNull null];
        }
    }
    else if ( [cachedFunction isEqual:[NSNull null]] ) {
        cachedFunction = nil;
    }

    return cachedFunction;
}

@end
