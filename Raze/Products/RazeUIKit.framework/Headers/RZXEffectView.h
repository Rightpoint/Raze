//
//  RZXEffectView.h
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXGLView.h>
#import <RazeEffects/RZXEffect.h>
#import <RazeCore/RZXTransform3D.h>

@interface RZXEffectView : RZXGLView

/**
 *  The effect to apply to the source view.
 *  @see RZXEffect
 */
@property (strong, nonatomic) RZXEffect *effect;

/**
 *  The transform with which to render the source view.
 */
@property (strong, nonatomic) RZXTransform3D *effectTransform;

/**
 *  Whether the contents of the view texture are updated each frame.
 *  If the source view contents never change, set this property to NO for best performance.
 */
@property (assign, nonatomic, getter=isDynamic) IBInspectable BOOL dynamic;

/**
 *  Whether the view texture should be updated synchronously. Default NO.
 *  @see RZXViewTexture
 */
@property (assign, nonatomic) BOOL synchronousUpdate;

/**
 *  Creates a new RZXEffect view that will apply an RZXEffect to a given view.
 *
 *  @param view    The view to apply an effect to. It must be currently on screen.
 *  @param effect  The effect to apply to the view.
 *  @param dynamic Whether the source view has dynamic contents. If the source will never change, pass NO.
 *
 *  @note The sourceView should NOT be an ancestor of the effect view.
 */
- (instancetype)initWithSourceView:(UIView *)view effect:(RZXEffect *)effect dynamicContent:(BOOL)dynamic;

@end

@interface RZXEffectView (RZUnavailable)

- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("Use -initWithSourceView: instead.")));

- (void)setMultisampleLevel:(GLsizei)multisampleLevel __attribute__((unavailable("RZXEffectView does not support multisample antialiasing.")));

- (id<RZXGLViewDelegate>)delegate __attribute__((unavailable("RZXEffectView does not support delegation.")));
- (void)setDelegate:(id<RZXGLViewDelegate>)delegate __attribute__((unavailable("RZXEffectView does not support delegation.")));

@end
