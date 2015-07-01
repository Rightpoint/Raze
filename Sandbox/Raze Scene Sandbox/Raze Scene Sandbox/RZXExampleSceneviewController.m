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
    self.sceneView.framesPerSecond = 60;
    self.sceneView.multisampleLevel = 4;

    RZXADSPhongEffect *effect = [RZXADSPhongEffect effect];
    effect.lightPosition = GLKVector4Make(0.0f, 10.0f, 20.0f, 0.0f);

    RZXScene *scene = [RZXScene sceneWithEffect: effect];

    RZXMesh *mesh = [RZXMesh meshWithName:@"firstMesh" meshFileName:@"cube.mesh"];
    RZXStaticTexture *texture = [RZXStaticTexture textureWithFileName:@"gridTexture.png" useMipMapping:YES useCache:YES];
    
    RZXModelNode *modelNode = [RZXModelNode modelNodeWithMesh:mesh texture:texture];
    modelNode.transform.translation = GLKVector3Make(0.0f, 0.0f, -9.0f);

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = [NSValue rzx_valueWithQuaternion:GLKQuaternionIdentity];
    animation.toValue = [NSValue rzx_valueWithQuaternion:GLKQuaternionMakeWithAngleAndAxis(M_PI, 0.0f, 1.0f, 0.0f)];
    animation.duration = 3.0;
    [modelNode addAnimation:animation forKey:@"rotation"];

    RZXTextNode *textNode = [RZXTextNode nodeWithText:@"This is a test"];
    textNode.font = [RZXFont systemFontOfSize:150.0f];
    textNode.textColor = [RZXColor purpleColor];
    textNode.transform.translation = GLKVector3Make(0.0f, 0.0f, 0.34f);
    [modelNode addChild:textNode];

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
