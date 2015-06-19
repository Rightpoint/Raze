//
//  ViewController.m
//  Raze Scene Sandbox
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "ViewController.h"

@import RazeScene;

@interface ViewController ()

@property (nonatomic, readonly) RZXSceneView *sceneView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sceneView.backgroundColor = [UIColor whiteColor];
    
    RZXScene *scene = [[RZXScene alloc] init];
    scene.camera = [RZXCamera cameraWithFieldOfView:GLKMathDegreesToRadians(30) aspectRatio:9.0/16.0 nearClipping:0.001 farClipping:50];

    RZXMesh *mesh = [RZXMesh meshWithName:@"cube" meshFileName:@"cube.mesh"];
    RZXTexture *texture = [RZXTexture textureWithFileName:@"confettiTexture.png" useMipMapping:NO useCache:YES];
    
    RZXModelNode *modelNode = [RZXModelNode modelNodeWithMesh:mesh texture:texture];
    modelNode.transform.translation = GLKVector3Make(0.0f, 0.0f, -10.0f);
    modelNode.transform.rotation = GLKQuaternionMakeWithAngleAndAxis(M_PI_4, 1.0f, 1.0f, 1.0f);

    [scene addChild:modelNode];

    self.sceneView.scene = scene;
    self.view.backgroundColor = [UIColor blueColor];
}

- (RZXSceneView *)sceneView
{
    return (RZXSceneView *)self.view;
}

@end
