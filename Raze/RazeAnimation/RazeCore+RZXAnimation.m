//
//  RazeCore+RZXAnimation.m
//  RazeAnimation
//
//  Created by Rob Visentin on 7/10/15.
//

#import <RazeAnimation/RazeCore+RZXAnimation.h>

#import <RazeCore/RZXTransform3D.h>
#import <RazeCore/RZXGLView.h>

@implementation NSObject (RZXAnimation)

+ (void)load
{
    @autoreleasepool {
        [[RZXTransform3D class] rzx_addKVCComplianceForGLKTypes];
        [[RZXGLView class] rzx_addKVCComplianceForGLKTypes];

        // RazeEffects integration
        [NSClassFromString(@"RZXEffect") rzx_addKVCComplianceForGLKTypes];
    }
}

@end
