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
    
    RZXScene *scene = [RZXScene sceneWithEffect: [RZXADSPhongEffect effect]];
    RZXMesh *mesh = [RZXMesh meshWithName:@"firstMesh" meshFileName:@"cube.mesh"];
    RZXTexture *texture = [RZXTexture textureWithFileName:@"gridTexture.png" useMipMapping:YES useCache:YES];
    
    __block RZXModelNode *modelNode = [RZXModelNode modelNodeWithMesh:mesh texture:texture];
    modelNode.transform.translation = GLKVector3Make(0.0f, 0.0f, -10.0f);
//    modelNode.transform.rotation = GLKQuaternionMakeWithAngleAndAxis(M_PI_4, 1.0f, 1.0f, 1.0f);
    GLKVector3 rotation = GLKVector3Make(0.0f, 6.0f, 0.0f);
    
    __block __weak RZXModelNode *weakModelNode = modelNode;
    
    modelNode.updateBlock = ^(NSTimeInterval dt){
        weakModelNode.transform.rotation = GLKQuaternionMultiply(weakModelNode.transform.rotation, GLKQuaternionMakeWithVector3(rotation, dt));

    };
    
    [scene addChild:modelNode];
    
    self.sceneView.scene = scene;
    self.view.backgroundColor = [UIColor blueColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.sceneView.scene.camera = [RZXCamera cameraWithFieldOfView:GLKMathDegreesToRadians(30) aspectRatio:9.0 / 16.0 nearClipping:0.001 farClipping:50];
}

- (RZXSceneView *)sceneView
{
    return (RZXSceneView *)self.view;
}

@end
