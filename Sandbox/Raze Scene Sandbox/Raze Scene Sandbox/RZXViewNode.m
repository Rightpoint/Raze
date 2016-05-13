//
//  RZXViewNode.m
//  Raze Scene Sandbox
//
//  Created by Rob Visentin on 8/7/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXViewNode.h"

@interface RZXViewNode ()

@property (weak, nonatomic) UIView *view;

@end

@implementation RZXViewNode

+ (instancetype)nodeWithView:(UIView *)view
{
    RZXViewNode *node = [super node];
    node.view = view;

    return node;
}

- (BOOL)setupGL
{
    self.material.texture = [RZXViewTexture textureWithSize:self.view.frame.size];

    return [super setupGL];
}

- (void)rzx_update:(NSTimeInterval)dt
{
    if ( [self.material.texture isKindOfClass:[RZXViewTexture class]] ) {
        [(RZXViewTexture *)self.material.texture updateWithView:self.view synchronous:YES];
    }

    [super rzx_update:dt];
}

@end
