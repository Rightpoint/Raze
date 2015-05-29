//
//  RZXNode.h
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RazeCore.h>

@class RZTransform3D;
@class RZEffect;
@class RZCamera;

@interface RZXNode : NSObject <RZXRenderable, RZXUpdateable>

@property (strong, nonatomic) NSMutableArray *children;
@property (strong, nonatomic) RZXNode *parent;
@property (strong, nonatomic) RZTransform3D *transform;
@property (strong, nonatomic) RZEffect *effect;
@property (strong, nonatomic) RZCamera *camera;

@end
