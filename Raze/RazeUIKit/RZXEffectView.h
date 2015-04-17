//
//  RZXEffectView.h
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXGLView.h>
#import <RazeCore/RZXEffect.h>
#import <RazeCore/RZXTransform3D.h>

@interface RZXEffectView : RZXGLView

@property (strong, nonatomic) RZXEffect *effect;
@property (strong, nonatomic) RZXTransform3D *effectTransform;

@property (assign, nonatomic, getter=isDynamic) IBInspectable BOOL dynamic;

@property (assign, nonatomic) BOOL synchronousUpdate; // default NO

- (instancetype)initWithSourceView:(UIView *)view effect:(RZXEffect *)effect dynamicContent:(BOOL)dynamic;

@end

@interface RZXEffectView (RZUnavailable)

- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("Use -initWithSourceView: instead.")));

@end
