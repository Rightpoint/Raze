//
//  RZXSceneView.h
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXGLView.h>

@class RZXScene;

@interface RZXSceneView : RZXGLView

@property (strong, nonatomic) RZXScene *scene;

- (instancetype)initWithSourceView:(UIView *)view scene:(RZXScene *)scene;

@end

@interface RZXSceneView (RZUnavailable)

- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("Use -initWithSourceView: instead.")));

@end
