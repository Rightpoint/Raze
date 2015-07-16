//
//  RZXViewTexture.m
//
//  Created by Rob Visentin on 1/9/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeUIKit/RZXViewTexture.h>

@implementation RZXViewTexture

+ (instancetype)textureWithSize:(CGSize)size
{
    return [self textureWithSize:size scale:[UIScreen mainScreen].scale];
}

- (void)updateWithView:(UIView *)view synchronous:(BOOL)synchronous
{
    if ( synchronous ) {
        [self rz_renderView:view];
    }
    else if ( dispatch_semaphore_wait([[self class] renderSemaphore], DISPATCH_TIME_NOW) == 0 ) {
        dispatch_async([[self class] renderQueue], ^{
            [self rz_renderView:view];
            
            dispatch_semaphore_signal([[self class] renderSemaphore]);
        });
    }
}

- (void)rzx_setupGL
{
    [super rzx_setupGL];

    [self applyOptions:@{ kRZXTextureSWrapKey : @(GL_CLAMP_TO_EDGE),
                          kRZXTextureTWrapKey : @(GL_CLAMP_TO_EDGE) }];
}

#pragma mark - private methods

+ (dispatch_queue_t)renderQueue
{
    static dispatch_queue_t s_RenderQueue = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_RenderQueue = dispatch_queue_create("com.razeeffects.view-texture-render", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(s_RenderQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    });

    return s_RenderQueue;
}

+ (dispatch_semaphore_t)renderSemaphore
{
    static dispatch_semaphore_t s_RenderSemaphore = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_RenderSemaphore = dispatch_semaphore_create(2);
    });

    return s_RenderSemaphore;
}

- (void)rz_renderView:(UIView *)view
{
    @autoreleasepool {
        [self updateWithBlock:^(RZXTexture *self, CGContextRef ctx) {
            UIGraphicsPushContext(ctx);
            [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
            UIGraphicsPopContext();
        }];
    }
}

@end
