//
//  CAAnimation+RZXPrivateExtensions.m
//  RazeScene
//
//  Created by Rob Visentin on 6/24/15.
//

#import <objc/runtime.h>
#import <RazeCore/RZXAnimatable.h>
#import <RazeCore/RZXInterpolationFunction.h>

#import "CAAnimation+RZXExtensions.h"

@interface RZXAnimationState : NSObject

@property (assign, nonatomic, getter=isStarted) BOOL started;
@property (assign, nonatomic, getter=isFinished) BOOL finished;

@property (assign, nonatomic) CFTimeInterval currentTime;
@property (assign, nonatomic) float repetition;

// TODO: add properties as needed

@end

@interface NSObject (RZXAnimationExtensions)

+ (RZXInterpolationFunction *)rzx_cachedInterpolationFunctionForKey:(NSString *)key;

@end

@implementation CAAnimation (RZXPrivateExtensions)

- (BOOL)isFinished
{
    return self.rzx_state.isFinished;
}

- (void)rzx_applyToObject:(NSObject *)object
{
    // base class no-ops. subclass override
    self.rzx_state.finished = YES;
}

- (void)rzx_interrupt
{
    RZXAnimationState *state = [self rzx_state];

    if ( state.isStarted && !state.isFinished ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate animationDidStop:self finished:NO];
        });
    }
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    RZXAnimationState *state = self.rzx_state;

    state.currentTime += dt;
    state.repetition += dt / self.duration;
}

#pragma mark - private methods

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

- (CFTimeInterval)rzx_interpolationFactorForTime:(CFTimeInterval)currentTime
{
    // TODO: take into account timing functions. This is just linear.
    return (currentTime / self.duration);
}

- (void)rzx_updateAnimationState:(RZXAnimationState *)state
{
    NSTimeInterval duration = self.duration;
    float repeatCount = self.repeatCount;
    CFTimeInterval repeatDuration = self.repeatDuration;

    if ( state.currentTime > 0.0 && !state.isStarted ) {
        state.started = YES;
    }

    if ( repeatCount > 0.0f && state.repetition >= repeatCount ) {
        state.currentTime = fmodf(repeatCount, 1.0f) * duration;
        state.repetition = repeatCount;
        state.finished = YES;
    }
    else if ( repeatDuration > 0.0 && state.repetition * duration >= repeatDuration ) {
        state.currentTime = fmodf(repeatDuration, duration);
        state.repetition = repeatDuration / duration;
        state.finished = YES;
    }
    else if ( state.currentTime >= self.duration ) {
        if ( repeatCount > 0.0f || repeatDuration > 0.0 ) {
            state.currentTime -= self.duration;
        }
        else {
            state.currentTime = self.duration;
            state.finished = YES;
        }
    }
}

@end

@implementation CABasicAnimation (RZXExtensions)

- (void)rzx_applyToObject:(NSObject *)object
{
    if ( self.isFinished ) {
        return;
    }

    id animatedObject = [object valueForKeyPath:[self.keyPath stringByDeletingPathExtension]];

    NSString *animatedKey = [self.keyPath pathExtension];

    RZXInterpolationFunction *interpolationFunction = [[animatedObject class] rzx_cachedInterpolationFunctionForKey:animatedKey];

    RZXAnimationState *state = [self rzx_state];
    BOOL previouslyStarted = state.isStarted;

    if ( interpolationFunction != nil ) {
        [self rzx_updateAnimationState:state];

        // TODO: also account for byValue combinations
        id interpolatedValue = [interpolationFunction interpolatedValueFrom:self.fromValue to:self.toValue t:[self rzx_interpolationFactorForTime:state.currentTime]];

        [animatedObject setValue:interpolatedValue forKey:animatedKey];
    }
    else {
        state.started = NO;
        state.finished = YES;
    }

    if ( !previouslyStarted && state.isStarted ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate animationDidStart:self];
        });
    }

    if ( state.isStarted && state.finished ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate animationDidStop:self finished:YES];
        });
    }
}

@end

@implementation NSObject (RZXAnimationExtensions)

+ (RZXInterpolationFunction *)rzx_cachedInterpolationFunctionForKey:(NSString *)key
{
    NSMutableDictionary *functionCache = objc_getAssociatedObject(self, _cmd);

    if ( functionCache == nil ) {
        functionCache = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, functionCache, OBJC_ASSOCIATION_RETAIN);
    }

    RZXInterpolationFunction *cachedFunction = functionCache[key];

    if ( cachedFunction == nil ) {
        if ( [self respondsToSelector:@selector(rzx_interpolationFunctionForKey:)] ) {
            cachedFunction = [(id<RZXAnimatable>)self rzx_interpolationFunctionForKey:key];

            functionCache[key] = cachedFunction ?: [NSNull null];
        }
    }
    else if ( [cachedFunction isEqual:[NSNull null]] ) {
        cachedFunction = nil;
    }

    return cachedFunction;
}

@end

@implementation RZXAnimationState
@end
