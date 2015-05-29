//
//  RZXMesh.h
//  RazeScene
//
//  Created by John Stricker on 3/19/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RazeCore.h>

@interface RZXMesh : NSObject<RZXRenderable>

+ (instancetype)meshWithName:(NSString *)name meshFileName:(NSString *)meshFileName;

@end
