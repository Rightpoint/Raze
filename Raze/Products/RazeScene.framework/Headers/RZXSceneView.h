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

// TODO: elimineate confusion between two seperate core renderables (scene here and model in RZXGLView)
@property (strong, nonatomic) RZXScene *scene;

- (instancetype)initWithFrame:(CGRect)frame scene:(RZXScene *)scene;

@end
