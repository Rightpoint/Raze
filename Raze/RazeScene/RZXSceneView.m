//
//  RZXSceneView.m
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXSceneView.h"
#import <RazeScene/RazeScene.h>

@interface RZXSceneView(RZProtected)

- (void)createBuffers;
- (void)destroyBuffers;

@end

@interface RZXSceneView() <RZXUpdateable, RZXRenderable>

@property (strong, nonatomic) IBOutlet UIView *sourceView;

@end

@implementation RZXSceneView

- (instancetype)initWithSourceView:(UIView *)view scene:(RZXScene *)scene
{
    self = [super initWithFrame:view.bounds];
    if (self) {
        _sourceView = view;
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
