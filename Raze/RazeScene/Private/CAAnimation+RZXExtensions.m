//
//  CAAnimation+RZXExtensions.m
//  RazeScene
//
//  Created by Rob Visentin on 6/24/15.
//

#import <objc/runtime.h>
#import <RazeCore/RZXAnimatable.h>
#import <RazeCore/RZXInterpolationFunction.h>

#import "CAAnimation+RZXExtensions.h"

@interface RZXAnimationState : NSObject

@property (assign, nonatomic, readonly, getter=isFinished) BOOL finished;

@property (assign, nonatomic) CFTimeInterval currentTime;

// TODO: add properties as needed

@end

@interface NSObject (RZXAnimationExtensions)

+ (RZXInterpolationFunction *)rzx_cachedInterpolationFunctionForKey:(NSString *)key;

@end

@implementation CAAnimation (RZXExtensions)

- (BOOL)isFinished
{
    return self.rzx_state.isFinished;
}

- (void)rzx_applyToObject:(NSObject *)object
{
    // no-op
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    self.rzx_state.currentTime += dt;
}

#pragma mark - private methods

- (RZXAnimationState *)rzx_state
{
    RZXAnimationState *state = objc_getAssociatedObject(self, _cmd);

    if ( state == nil ) {
        state = [[RZXAnimationState alloc] init];
        objc_setAssociatedObject(self, _cmd, state, OBJC_ASSOCIATION_RETAIN);
    }

    return state;
}

@end

@implementation CABasicAnimation (RZXExtensions)

- (void)rzx_applyToObject:(NSObject *)object
{
    id animatedObject = [object valueForKeyPath:[self.keyPath stringByDeletingPathExtension]];

    NSString *animatedKey = [self.keyPath pathExtension];

    RZXInterpolationFunction *interpolationFunction = [[animatedObject class] rzx_cachedInterpolationFunctionForKey:animatedKey];

    if ( interpolationFunction != nil ) {
        // TODO: also account for byValue combinations
        // TODO: take into account timing functions
        NSTimeInterval t = (self.rzx_state.currentTime / self.duration);
        id interpolatedValue = [interpolationFunction interpolatedValueFrom:self.fromValue to:self.toValue t:t];

        [animatedObject setValue:interpolatedValue forKey:animatedKey];
    }

    // TODO: update finished state and fire delegate methods as necessary
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

// TODO: manage state

@end
