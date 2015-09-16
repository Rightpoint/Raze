//
//  RZXBasicAnimation.h
//  RazeAnimation
//
//  Created by Rob Visentin on 7/13/15.
//

#import <RazeAnimation/RZXAnimationBase.h>

@interface RZXBasicAnimation : CABasicAnimation

+ (instancetype)animationWithKeyPath:(NSString *)path options:(RZXAnimationOptions)options;

@end
