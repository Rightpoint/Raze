//
//  RZXTransform3D.h
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <GLKit/GLKMath.h>
#import <RazeCore/RZXAnimatable.h>

@interface RZXTransform3D : NSObject <NSCopying, RZXAnimatable>

@property (nonatomic, assign) GLKVector3 translation;
@property (nonatomic, assign) GLKQuaternion rotation;
@property (nonatomic, assign) GLKVector3 scale;

@property (nonatomic, readonly) GLKMatrix4 modelMatrix;

+ (instancetype)transform;
+ (instancetype)transformWithTranslation:(GLKVector3)trans rotation:(GLKQuaternion)rot scale:(GLKVector3)scale;

@end
