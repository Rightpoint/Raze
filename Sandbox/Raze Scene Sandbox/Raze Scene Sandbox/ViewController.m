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
    
    RZXScene *scene = [[RZXScene alloc] init];
    scene.camera = [RZXCamera cameraWithFieldOfView:GLKMathDegreesToRadians(35) aspectRatio:3/4 nearClipping:0.1 farClipping:50];

    RZXMesh *mesh = [RZXMesh meshWithName:@"cube" meshFileName:@"cube.mesh"];
    RZXTexture *texture = [RZXTexture textureWithFileName:@"confettiTexture.png" useMipMapping:NO useCache:YES];
    
    RZXModelNode *modelNode = [RZXModelNode modelNodeWithMesh:mesh texture:texture];
    modelNode.transform.translation = GLKVector3Make(0.0f, 0.0f, -5.0f);

    [scene addChild:modelNode];

    self.sceneView.scene = scene;
}

- (RZXSceneView *)sceneView
{
    return (RZXSceneView *)self.view;
}

@end
