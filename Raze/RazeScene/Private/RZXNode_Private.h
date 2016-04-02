//
//  RZXNode_Private.h
//  Raze
//
//  Created by Rob Visentin on 4/1/16.
//
//

#import <RazeScene/RZXNode.h>
#import <RazePhysics/RZXPhysicsWorld.h>

@class RZXScene;

@interface RZXNode ()

@property (weak, nonatomic) RZXScene *scene;

- (void)revertToSnapshot;

@end

@interface RZXPhysicsBody ()

@property (weak, nonatomic) RZXNode *node;

@end
