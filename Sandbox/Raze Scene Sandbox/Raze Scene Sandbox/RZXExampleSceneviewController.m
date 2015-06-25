//
//  RZXExampleSceneviewController.m
//  Raze Scene Sandbox
//
//  Created by John Stricker on 6/22/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXExampleSceneviewController.h"
@import RazeCore;
@import RazeScene;
@import RazeEffects;

@interface RZXExampleSceneviewController ()

@property (nonatomic, readonly) RZXSceneView *sceneView;

@end

@implementation RZXExampleSceneviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sceneView.backgroundColor = [UIColor whiteColor];
    self.sceneView.framesPerSecond = 30;
    self.sceneView.multisampleLevel = 0;

    RZXADSPhongEffect *effect = [RZXADSPhongEffect effect];
    effect.lightPosition = GLKVector4Make(3.0f, 5.0f, 20.0f, 0.0f);

    RZXScene *scene = [RZXScene sceneWithEffect: effect];

    RZXMesh *mesh = [RZXMesh meshWithName:@"firstMesh" meshFileName:@"cube.mesh"];
    RZXTexture *texture = [RZXTexture textureWithFileName:@"rzMetal256.png" useMipMapping:YES useCache:YES];
    
    RZXModelNode *modelNode = [RZXModelNode modelNodeWithMesh:mesh texture:texture];
    modelNode.transform.translation = GLKVector3Make(0.0f, 0.0f, -8.0f);

//    NSValue *trans = [modelNode.transform valueForKey:@"translation"];
//    GLKVector3 vec = [trans rzx_vec3Value];

    

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.fromValue = @(0.0f);
    animation.toValue = @(1.0f);
    animation.duration = 3.0;

    [modelNode addAnimation:animation forKey:@"rotation"];

    [scene addChild:modelNode];
    
    self.sceneView.scene = scene;
    self.view.backgroundColor = [UIColor blueColor];
}

- (void)viewWillLayoutSubviews
{
    float ratio = CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds);
    self.sceneView.scene.camera = [RZXCamera cameraWithFieldOfView:GLKMathDegreesToRadians(30) aspectRatio:ratio nearClipping:0.001 farClipping:50];
}

- (RZXSceneView *)sceneView
{
    return (RZXSceneView *)self.view;
}

@end
