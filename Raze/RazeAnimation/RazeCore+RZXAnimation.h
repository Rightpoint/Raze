//
//  RazeCore+RZXAnimation.h
//  RazeAnimation
//
//  Created by Rob Visentin on 7/10/15.
//

#import <RazeCore/RZXCamera.h>

#import <RazeAnimation/RZXAnimatable.h>
#import <RazeAnimation/RZXAnimator.h>

/**
 *  Adds KVC compliance for GLKit math types for Raze objects.
 */
@interface NSObject (RZXAnimation)
@end

@interface RZXCamera (RZXAnimation)

@property (nonatomic, readonly) RZXAnimator *animator;

@end
