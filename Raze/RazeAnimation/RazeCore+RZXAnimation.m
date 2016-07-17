//
//  RazeCore+RZXAnimation.m
//  RazeAnimation
//
//  Created by Rob Visentin on 7/10/15.
//

#import <objc/runtime.h>

#import <RazeAnimation/RazeCore+RZXAnimation.h>

#import <RazeCore/RZXTransform3D.h>
#import <RazeCore/RZXGLView.h>
#import <RazeEffects/RZXEffect.h>

@implementation NSObject (RZXAnimation)

+ (void)load
{
    @autoreleasepool {
        [[RZXTransform3D class] rzx_addKVCComplianceForGLKTypes];
        [[RZXCamera class] rzx_addKVCComplianceForGLKTypes];
        [[RZXEffect class] rzx_addKVCComplianceForGLKTypes];
        [[RZXGLView class] rzx_addKVCComplianceForGLKTypes];
    }
}

@end

@implementation RZXCamera (RZXAnimation)

- (RZXAnimator *)animator
{
    RZXAnimator *animator = objc_getAssociatedObject(self, _cmd);

    if ( animator == nil ) {
        animator = [RZXAnimator animatorForObject:self];
        [self setAnimator:animator];
    }

    return animator;
}

- (void)setAnimator:(RZXAnimator *)animator
{
    objc_setAssociatedObject(self, @selector(animator), animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
