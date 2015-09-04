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
 *  The basic node used for 3D Models. It contains a mesh object containing the model's construction data and a texture object that will be applied to the model.
 */
@interface RZXModelNode : RZXNode

/**
 *  Contains the model data used by this node
 */
@property (strong, nonatomic) RZXMesh *mesh;

/**
 *  2D texture to be applied to the mesh
 */
@property (strong, nonatomic) RZXTexture *texture;

/**
 *  Initialize a node
 *
 *  @param mesh    mesh for this node
 *  @param texture texture for this node
 *
 *  @return initialized model node
 */
+ (instancetype)modelNodeWithMesh:(RZXMesh *)mesh texture:(RZXTexture *)texture;

@end
