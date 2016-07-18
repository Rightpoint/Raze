//
//  RZXAnimator.m
//  RazeAnimation
//
//  Created by Rob Visentin on 7/15/16.
//

#import <RazeAnimation/RZXAnimator.h>
#import <RazeAnimation/CAAnimation+RZXExtensions.h>
#import <RazeAnimation/RZXAnimatable.h>

@implementation RZXAnimator {
    NSMutableDictionary *_mutableAnimations;
}

+ (instancetype)animatorForObject:(id)animatedObject
{
    return [[self alloc] initWithObject:animatedObject];
}

- (instancetype)init
{
    return [self initWithObject:nil];
}

- (instancetype)initWithObject:(id)animatedObject
{
    if ( (self = [super init]) ) {
        _mutableAnimations = [NSMutableDictionary dictionary];
        _animatedObject = animatedObject;
    }
    return self;
}

- (NSArray *)animations
{
    return [_mutableAnimations allValues];
}

- (void)addAnimation:(CAAnimation *)animation forKey:(NSString *)key
{
    animation = [animation copy];
    key = key ?: [NSString stringWithFormat:@"%p", animation];
    [self removeAnimationForKey:key];
    _mutableAnimations[key] = animation;
}

- (CAAnimation *)animationForKey:(NSString *)key
{
    return [_mutableAnimations[key] copy];
}

- (void)removeAnimationForKey:(NSString *)key
{
    [_mutableAnimations[key] rzx_interrupt];
    [_mutableAnimations removeObjectForKey:key];
}

- (void)removeAllAnimations
{
    for ( NSString *key in [_mutableAnimations allKeys] ) {
        [self removeAnimationForKey:key];
    }
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    id animatedObject = self.animatedObject;

    for ( NSString *key in _mutableAnimations.allKeys ) {
        CAAnimation *animation = _mutableAnimations[key];

        [animation rzx_update:dt];
        [animation rzx_applyToObject:animatedObject];

        if ( animation.rzx_isFinished ) {
            [_mutableAnimations removeObjectForKey:key];
        }
    }
}

@end
