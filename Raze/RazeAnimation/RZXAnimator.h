//
//  RZXAnimator.h
//  RazeAnimation
//
//  Created by Rob Visentin on 7/15/16.
//

#import <RazeCore/RZXUpdateable.h>
#import <RazeAnimation/RZXAnimationBase.h>

@interface RZXAnimator : NSObject <RZXUpdateable>

@property (weak, nonatomic, readonly) id animatedObject;
@property (nonatomic, readonly) NSArray *animations;

- (void)addAnimation:(CAAnimation *)animation forKey:(NSString *)key;

- (CAAnimation *)animationForKey:(NSString *)key;

- (void)removeAnimationForKey:(NSString *)key;
- (void)removeAllAnimations;

+ (instancetype)animatorForObject:(id)animatedObject;
- (instancetype)initWithObject:(id)animatedObject;

@end
