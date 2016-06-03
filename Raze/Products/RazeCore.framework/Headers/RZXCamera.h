//
//  RZXCamera.h
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXTransform3D.h>

/**
 *  An object representing a projective camera.
 */
@interface RZXCamera : NSObject <NSCopying>

/**
 *  An identifier for use by your application.
 */
@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) RZXTransform3D *transform;

/** A unit vector in the "up" direction. Default is (0, 1, 0) */
@property (nonatomic, assign) GLKVector3 up;

@property (nonatomic, assign) float fieldOfView;

@property (nonatomic, assign) float aspectRatio;

/** The near clipping plane. Must be positive. */
@property (nonatomic, assign) float near;

/** The far clipping plane. Must be positive. */
@property (nonatomic, assign) float far;

/** The current view matrix based on the camera's transform and up properties. */
@property (nonatomic, readonly) GLKMatrix4 viewMatrix;

/** The current projection matrix of the camera based on the fieldOfView, aspectRatio, near, and far properties.
 *  @note This value is cached, so is not recomputed unless a contributing property changes.
 */
@property (nonatomic, readonly) GLKMatrix4 projectionMatrix;

+ (instancetype)cameraWithFieldOfView:(float)fov aspectRatio:(float)aspectRatio nearClipping:(float)near farClipping:(float)far;

@end
