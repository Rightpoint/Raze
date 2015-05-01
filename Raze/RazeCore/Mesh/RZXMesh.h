//
//  RZXMesh.h
//  RZXSceneDemo
//
//  Created by John Stricker on 3/19/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RazeCore.h>

@interface RZXMesh : NSObject<RZXRenderable>

+ (instancetype)meshWithName:(NSString *)name meshFileName:(NSString *)meshFileName;

@end
