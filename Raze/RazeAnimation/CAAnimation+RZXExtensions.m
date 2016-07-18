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

static NSString* const kRZXAnimationStartBlockKey = @"_RZXAnimationStartBlock";
static NSString* const kRZXAnimationCompletionBlockKey = @"_RZXAnimationCompletionBlock";

#pragma mark - NSObject+RZXAnimationExtensions

@interface NSObject (RZXAnimationExtensions)

+ (RZXInterpolator *)rzx_cachedInterpolatorForKey:(NSString *)key;

@end

@implementation CAAnimation (RZXExtensions)

- (RZXAnimationStartBlock)rzx_startBlock
{
    return [self valueForKey:kRZXAnimationStartBlockKey];
}

- (void)rzx_setStartBlock:(RZXAnimationStartBlock)rzx_startBlock
{
    [self setValue:rzx_startBlock forKey:kRZXAnimationStartBlockKey];
}

- (RZXAnimationCompletionBlock)rzx_completionBlock
{
    return [self valueForKey:kRZXAnimationCompletionBlockKey];
}

- (void)rzx_setCompletionBlock:(RZXAnimationCompletionBlock)rzx_completion
{
    [self setValue:[rzx_completion copy] forKey:kRZXAnimationCompletionBlockKey];
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
    // base class is a no-op. subclasses override
    self.rzx_state.finished = YES;
}

- (void)rzx_interrupt
{
    RZXAnimationState *state = [self rzx_state];

    if ( state.isStarted && !state.isFinished ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( [self.delegate respondsToSelector:@selector(animationDidStop:finished:)] ) {
                [self.delegate animationDidStop:self finished:NO];
            }

            if ( self.rzx_completionBlock != nil ) {
                self.rzx_completionBlock(self, NO);
            }
        });
    }
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    RZXAnimationState *state = self.rzx_state;
    dt = dt * self.speed;

    state.currentTime += dt;

    if ( self.duration != 0.0 ) {
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

    if ( interpolator != nil ) {
        id currentValue = [animatedObject valueForKey:animatedKey];

        if ( [state updateWithAnimation:self] ) {
            [self rzx_seedInitialAndTargetValuesForState:state withInterpolator:interpolator currentValue:currentValue];
        }

        id interpolatedValue = [self rzx_interpolateAtTime:state.currentTime withInterpolator:interpolator currentValue:currentValue];

        [animatedObject setValue:interpolatedValue forKey:animatedKey];
    }
    else {
        state.started = NO;
        state.finished = YES;
    }

    if ( !previouslyStarted && state.isStarted ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( [self.delegate respondsToSelector:@selector(animationDidStart:)] ) {
                [self.delegate animationDidStart:self];
            }

            if ( self.rzx_startBlock != nil ) {
                self.rzx_startBlock(self);
            }
        });
    }

    if ( state.isStarted && state.finished ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( [self.delegate respondsToSelector:@selector(animationDidStop:finished:)] ) {
                [self.delegate animationDidStop:self finished:YES];
            }

            if ( self.rzx_completionBlock != nil ) {
                self.rzx_completionBlock(self, YES);
            }
        });
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
