//
//  CAAnimation+RZXPrivateExtensions.m
//  RazeAnimation
//
//  Created by Rob Visentin on 6/24/15.
//

#import <objc/runtime.h>
#import <RazeAnimation/CAAnimation+RZXPrivateExtensions.h>
#import <RazeAnimation/RZXAnimationState.h>
#import <RazeAnimation/RZXAnimatable.h>
#import <RazeAnimation/RZXInterpolator.h>

@interface NSObject (RZXAnimationExtensions)

+ (RZXInterpolator *)rzx_cachedInterpolatorForKey:(NSString *)key;

@end

@implementation CAAnimation (RZXPrivateExtensions)

- (RZXAnimationState *)rzx_state
{
    // NOTE: this value is NOT copied with -copy. Therefore all copies have fresh state.
    RZXAnimationState *state = objc_getAssociatedObject(self, _cmd);

    if ( state == nil ) {
        state = [[RZXAnimationState alloc] init];
        objc_setAssociatedObject(self, _cmd, state, OBJC_ASSOCIATION_RETAIN);
    }

    return state;
}

- (float)rzx_interpolationFactorForTime:(CFTimeInterval)currentTime
{
    // TODO: take into account timing functions. This is just linear.
    return (self.speed * currentTime / self.duration);
}

- (id)rzx_interpolateAtTime:(CFTimeInterval)time withInterpolator:(RZXInterpolator *)interpolator currentValue:(id)currentValue
{
    // subclass override
    return nil;
}

@end

@implementation CABasicAnimation (RZXExtensions)

#pragma mark - overrides

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

    if ( !previouslyStarted && state.isStarted && [self.delegate respondsToSelector:@selector(animationDidStart:)] ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate animationDidStart:self];
        });
    }

    if ( state.isStarted && state.finished && [self.delegate respondsToSelector:@selector(animationDidStop:finished:)] ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate animationDidStop:self finished:YES];
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

#pragma mark - private methods

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
