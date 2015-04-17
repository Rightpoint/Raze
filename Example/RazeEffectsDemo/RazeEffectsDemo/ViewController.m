//
//  ViewController.m
//  RazeEffectsDemo
//
//  Created by Rob Visentin on 1/15/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "ViewController.h"

@import RazeUIKit;
@import RazeEffects;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) RZXEffectView *effectView;
@property (strong, nonatomic) RZXClothEffect *effect;

@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        [self.contentView.subviews[1] setAlpha:0.0f];
    } completion:nil];
    
    [UIView animateWithDuration:3.0 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        [(UIView *)self.contentView.subviews[2] setTransform:CGAffineTransformMakeTranslation(200.0f, 0.0f)];
    } completion:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ( self.effectView == nil ) {
        self.effect = [RZXClothEffect effect];
        
//        uncomment this line for a super shiny cloth
//        self.effect.lightOffset = GLKVector3Make(0.0f, 1.1f, -3.0f);
        
        self.effectView = [[RZXEffectView alloc] initWithSourceView:self.contentView effect:self.effect dynamicContent:YES];
        self.effectView.backgroundColor = [UIColor blackColor];
        self.effectView.framesPerSecond = 60;
        
        self.effectView.effectTransform.rotation = GLKQuaternionMake(-0.133518726, 0.259643972, 0.0340433009, 0.955821096);
        
        [self.view addSubview:self.effectView];
    }
}

- (IBAction)sliderChanged:(UISlider *)slider
{
    self.effect.waveAmplitude = 0.05f + 0.2f * slider.value;
}

@end
