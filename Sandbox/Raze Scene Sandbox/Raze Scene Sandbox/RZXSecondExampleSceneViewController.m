//
//  RZXSecondExampleSceneViewController.m
//  Raze Scene Sandbox
//
//  Created by John Stricker on 6/23/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXSecondExampleSceneViewController.h"

@import RazeScene;
@import RazeEffects;

@interface RZXSecondExampleSceneViewController ()

@property (nonatomic, readonly) RZXSceneView *sceneView;

@end

@implementation RZXSecondExampleSceneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sceneView.backgroundColor = [UIColor whiteColor];
    self.sceneView.framesPerSecond = 60;
    self.sceneView.multisampleLevel = 4;
    
    RZXScene *scene = [RZXScene sceneWithEffect: [RZXADSPhongEffect effect]];
    RZXMesh *mesh = [RZXMesh meshWithName:@"secondMesh" meshFileName:@"torus.mesh"];
    RZXTexture *texture = [RZXTexture textureWithFileName:@"gridTexture.png" useMipMapping:YES useCache:YES];
    
    __block RZXModelNode *modelNode = [RZXModelNode modelNodeWithMesh:mesh texture:texture];
    modelNode.transform.translation = GLKVector3Make(0.0f, 0.0f, -6.0f);
    GLKVector3 rotation = GLKVector3Make(0.0f, 6.0f, 0.0f);
    __block __weak RZXModelNode *weakModelNode = modelNode;
    
    modelNode.updateBlock = ^(NSTimeInterval dt){
        weakModelNode.transform.rotation = GLKQuaternionMultiply(weakModelNode.transform.rotation, GLKQuaternionMakeWithVector3(rotation, dt));
        
    };
    
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
