//
//  RZXTransform3D.h
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <GLKit/GLKMath.h>

@interface RZXTransform3D : NSObject <NSCopying>

@property (nonatomic, assign) GLKVector3 translation;
@property (nonatomic, assign) GLKQuaternion rotation;
@property (nonatomic, assign) GLKVector3 scale;

/** 
 *  Returns the current TRS matrix from the translation, rotation, and scale properties.
 *  @note This matrix is cached, and therefore is not recomputed unless a contributing property changes.
 */
@property (nonatomic, readonly) GLKMatrix4 modelMatrix;

+ (instancetype)transform;
+ (instancetype)transformWithTranslation:(GLKVector3)trans rotation:(GLKQuaternion)rot scale:(GLKVector3)scale;

// delta is added to current value
- (void)translateXBy:(float)dx;
- (void)translateYBy:(float)dy;
- (void)translateZBy:(float)dz;

// current value is set to given value
- (void)translateXTo:(float)tx;
- (void)translateYTo:(float)ty;
- (void)translateZTo:(float)tz;

// current value is multiplied by delta
- (void)scaleXBy:(float)dx;
- (void)scaleYBy:(float)dy;
- (void)scaleZBy:(float)dz;

// current value is set to given value
- (void)scaleXTo:(float)sx;
- (void)scaleYTo:(float)sy;
- (void)scaleZTo:(float)sz;

// current rotation is multiplied by given quaternion
- (void)rotateXBy:(float)angle;
- (void)rotateYBy:(float)angle;
- (void)rotateZBy:(float)angle;
- (void)rotateBy:(GLKQuaternion)rotation;

@end
