//
//  RZXTransform3D.h
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXMath.h>

@interface RZXTransform3D : NSObject <NSCopying>

@property (nonatomic, assign) GLKVector3 translation;
@property (nonatomic, assign) GLKQuaternion rotation;
@property (nonatomic, assign) GLKVector3 scale;

/**
 *  Returns the Euler angles (angle around x, y, z) for the current rotation.
 *  Setting this property also sets the rotation property accordingly.
 */
@property (nonatomic, assign) GLKVector3 eulerAngles;

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
- (void)translateBy:(GLKVector3)translation;

// current value is set to given value
- (void)translateXTo:(float)tx;
- (void)translateYTo:(float)ty;
- (void)translateZTo:(float)tz;

// current value is multiplied by delta
- (void)scaleXBy:(float)dx;
- (void)scaleYBy:(float)dy;
- (void)scaleZBy:(float)dz;
- (void)scaleBy:(GLKVector3)scale;

// current value is set to given value
- (void)scaleXTo:(float)sx;
- (void)scaleYTo:(float)sy;
- (void)scaleZTo:(float)sz;

// current rotation is multiplied by given quaternion
- (void)rotateXBy:(float)angle;
- (void)rotateYBy:(float)angle;
- (void)rotateZBy:(float)angle;
- (void)rotateBy:(GLKQuaternion)rotation;

// current Euler angles are set to the given value
- (void)rotateXTo:(float)angle;
- (void)rotateYTo:(float)angle;
- (void)rotateZTo:(float)angle;

/**
 *  Concatenates the given transform's translation, scale, and rotation properties with the receivers own.
 */
- (void)transformBy:(RZXTransform3D *)transform;


/**
 *  Inverts the receiver's translation, scale, and rotation properties.
 */
- (void)invert;

/**
 *  Returns a transform created by inverting the receiver's translation, scale, and rotation properties.
 */
- (RZXTransform3D *)invertedTransform;

@end
