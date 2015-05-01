//
//  RZXModel.h
//  RZXSceneDemo
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZXNode.h"

@class RZXMesh;

@interface RZXModel : RZXNode

@property (strong, nonatomic) RZXMesh *mesh;
@property (assign, nonatomic) GLuint texture0;

@end
