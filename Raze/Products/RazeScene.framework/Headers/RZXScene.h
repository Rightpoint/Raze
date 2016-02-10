//
//  RZXScene.h
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeScene/RZXNode.h>

@interface RZXScene : RZXNode

/**
 *  The root node of the scene. 
 *  Children of the scene should be added to this node instead of the scene itself to ensure proper transform heirarchy.
 *  Animations and transforms that should affect the entire scene should be set on this node.
 */
@property (nonatomic, readonly) RZXNode *rootNode;

+ (instancetype)scene;
+ (instancetype)sceneWithEffect:(RZXEffect *)effect;

/**
 *  The class to use when initializing the scene's root node.
 */
+ (Class)rootNodeClass;

@end
