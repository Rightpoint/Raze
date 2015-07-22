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

    RZXMesh *mesh = [RZXMesh meshWithName:@"cube" usingCache:YES];
    RZXStaticTexture *texture = [RZXStaticTexture mipmappedTextureFromFile:@"gridTexture.png" usingCache:YES];
    
    RZXModelNode *modelNode = [RZXModelNode modelNodeWithMesh:mesh texture:texture];
    [modelNode.transform translateZBy:-9.0f];

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.byValue = [NSValue rzx_valueWithQuaternion:GLKQuaternionMakeWithAngleAndAxis(M_PI, 0.0f, 1.0f, 0.0f)];
    animation.duration = 3.0;
    animation.repeatCount = 1;
    [modelNode addAnimation:animation forKey:@"rotation"];

    RZXTextNode *textNode = [RZXTextNode nodeWithText:@"This is a test"];
    textNode.font = [RZXFont systemFontOfSize:50.0f];
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
