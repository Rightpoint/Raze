//
//  RZXModeNodel.h
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeScene/RZXNode.h>

@class RZXMesh;
@class RZXBaseTexture;

@interface RZXModelNode : RZXNode

@property (strong, nonatomic) RZXMesh *mesh;
@property (strong, nonatomic) RZXBaseTexture *texture;

+ (instancetype)modelNodeWithMesh:(RZXMesh *)mesh texture:(RZXBaseTexture *)texture;

@end
