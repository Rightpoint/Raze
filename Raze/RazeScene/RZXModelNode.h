//
//  RZXModeNodel.h
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeScene/RZXNode.h>

@class RZXMesh;
@class RZXTexture;

/**
 *  The basic node used for 3D Models. It contains a mesh object referencing the model data and a texture object representing the model's texture.
 */
@interface RZXModelNode : RZXNode

@property (strong, nonatomic) RZXMesh *mesh;
@property (strong, nonatomic) RZXTexture *texture;

/**
 *  Initialize a node
 *
 *  @param mesh    mesh for this node
 *  @param texture texture for this node
 *
 *  @return initizlied model node
 */
+ (instancetype)modelNodeWithMesh:(RZXMesh *)mesh texture:(RZXTexture *)texture;

@end
