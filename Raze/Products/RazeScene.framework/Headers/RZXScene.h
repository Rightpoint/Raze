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
 *  The parent node of a scene.
 *
 *  @param effect effect to apply to the scene
 *
 *  @return RZXScene
 */
+ (instancetype)sceneWithEffect:(RZXEffect *)effect;

@end
