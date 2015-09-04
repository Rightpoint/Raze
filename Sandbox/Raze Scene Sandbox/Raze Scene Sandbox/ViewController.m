//
//  ViewController.m
//  Raze Scene Sandbox
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "ViewController.h"
#import "RZXViewNode.h"

@interface ViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet RZXSceneView *sceneView;
@property (nonatomic, strong) RZXModelNode *officeNode;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSArray *names;

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
    scene.camera = [RZXCamera cameraWithFieldOfView:GLKMathDegreesToRadians(35) aspectRatio:ratio nearClipping:0.001 farClipping:50];
    [scene.camera.transform setTranslation:GLKVector3Make(0.0, 1.0, 3.9)];
    [scene.camera.transform rotateXBy:-0.25];

    self.sceneView.scene = scene;

    RZXMesh *officeMesh = [RZXMesh meshWithName:@"retroOffice" usingCache:YES];
    RZXStaticTexture *officeTexture = [RZXStaticTexture textureFromFile:@"officeTexture.png" usingCache:YES];

    RZXModelNode *officeNode = [RZXModelNode modelNodeWithMesh:officeMesh texture:officeTexture];
    [scene addChild:officeNode];
    self.officeNode = officeNode;

    RZXMesh *screenMesh = [RZXMesh meshWithName:@"officeScreen" usingCache:YES];
    RZXViewNode *screenNode = [RZXViewNode nodeWithView:self.tableView.superview];
    screenNode.mesh = screenMesh;
    [officeNode addChild:screenNode];

    [self configureGestureRecognizers];
    [self configureNames];
}

- (void)configureGestureRecognizers
{
    self.view.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:panRecognizer];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapRecognizer];

    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchRecognizer];

    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPressRecognizer];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)configureNames
{
    self.names = @[ @"Nick Bonatsakis",
                    @"Matt Buckley",
                    @"Dave Counts",
                    @"Anik Das",
                    @"Adam Faja",
                    @"Gary Fortier",
                    @"Michael Gorbach",
                    @"Jon Green",
                    @"Chris Hoogewerff",
                    @"Joe Howard",
                    @"Adam Howitt",
                    @"Dylan James",
                    @"Ben Johnson",
                    @"Justin Kaufman",
                    @"Brian King",
                    @"Matt Lawson",
                    @"Michael LeBarron",
                    @"Richard Lucas",
                    @"Adam Nelsen",
                    @"Jason Petralia",
                    @"Jenn  Pleus",
                    @"Greg Raiz",
                    @"Alex Rouse",
                    @"Aimee Silverman",
                    @"Eric Slosser",
                    @"Mallory Sluetz",
                    @"John Stricker",
                    @"Rob Visentin",
                    @"Hallie Verrier",
                    @"John Watson",
                    @"Josh Wilson"];
}

- (void)handlePan:(UIPanGestureRecognizer *)panRecognizer
{
    [self.officeNode.transform rotateYBy: [panRecognizer velocityInView:self.view].x * 0.0005];
}

- (void)handleTap:(UITapGestureRecognizer *)tapRecognizer
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.toValue = [NSValue rzx_valueWithQuaternion:GLKQuaternionMakeWithAngleAndAxis(0.0, 0.0, 0.0, 0.0)];
    animation.duration = 0.2;
    [self.officeNode addAnimation:animation forKey:@"rotation"];

    CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
    animation.toValue = [NSValue rzx_valueWithVec3:GLKVector3Make(0.0, 0.0, 0.0)];
    animation.duration = 0.2;
    [self.officeNode addAnimation:translationAnimation forKey:@"translation"];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchRecognizer
{
    [self.officeNode.transform translateZBy:pinchRecognizer.velocity * 0.01];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
    animation.toValue = [NSValue rzx_valueWithVec3:GLKVector3Make(0.0, 0.74, 3.5)];
    animation.duration = 1.0;

    [self.officeNode addAnimation:animation forKey:@"translation"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.names.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];

    cell.textLabel.text = self.names[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

@end
