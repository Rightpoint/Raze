//
//  ViewController.m
//  Raze Scene Sandbox
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (nonatomic, readonly) RZXSceneView *sceneView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sceneView.backgroundColor = [UIColor whiteColor];
    self.sceneView.framesPerSecond = 60;
    self.sceneView.multisampleLevel = 4;
    
    RZXADSPhongEffect *effect = [RZXADSPhongEffect effect];
    effect.lightPosition = GLKVector4Make(0.0f, 10.0f, 20.0f, 0.0f);

    RZXScene *scene = [RZXScene sceneWithEffect: effect];
    float ratio = CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds);
    scene.camera = [RZXCamera cameraWithFieldOfView:GLKMathDegreesToRadians(30) aspectRatio:ratio nearClipping:0.001 farClipping:50];
    [scene.camera.transform setTranslation:GLKVector3Make(0.0, 1.0, 3.9)];
    [scene.camera.transform rotateXBy:-0.25];

    self.sceneView.scene = scene;

    RZXMesh *officeMesh = [RZXMesh meshWithName:@"retroOffice" usingCache:YES];
    RZXStaticTexture *officeTexture = [RZXStaticTexture textureFromFile:@"greyTexture.png" usingCache:YES];

    RZXModelNode *officeNode = [RZXModelNode modelNodeWithMesh:officeMesh texture:officeTexture];
    [scene addChild:officeNode];

    RZXMesh *screenMesh = [RZXMesh meshWithName:@"officeScreen" usingCache:YES];
    RZXStaticTexture *screenTexture = [RZXStaticTexture textureFromFile:@"rzUnicorn.png" usingCache:YES];
    RZXModelNode *screenNode = [RZXModelNode modelNodeWithMesh:screenMesh texture:screenTexture];
    [officeNode addChild:screenNode];


    /*
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.byValue = [NSValue rzx_valueWithQuaternion:GLKQuaternionMakeWithAngleAndAxis(M_PI, 0.0f, 1.0f, 0.0f)];
    animation.duration = 3.0;
    animation.repeatCount = 1000;
    [modelNode addAnimation:animation forKey:@"rotation"];
*/
    RZXTextNode *textNode = [RZXTextNode nodeWithText:@"This is a test"];
    textNode.font = [RZXFont systemFontOfSize:50.0f];
    textNode.textColor = [RZXColor purpleColor];
    textNode.transform.translation = GLKVector3Make(0.0f, 0.0f, 0.34f);
  //  [modelNode addChild:textNode];



}

- (RZXSceneView *)sceneView
{
    return (RZXSceneView *)self.view;
}

@end
