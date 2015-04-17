//
//  RZXCamera.h
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXTransform3D.h>

@interface RZXCamera : NSObject

@property (strong, nonatomic) RZXTransform3D *transform;

@property (nonatomic, assign) GLKVector3 up;

@property (nonatomic, assign) float fieldOfView;

@property (nonatomic, assign) float aspectRatio;

/** The near clipping plane. Must be positive. */
@property (nonatomic, assign) float near;

/** The far clipping plane. Must be positive. */
@property (nonatomic, assign) float far;

@property (nonatomic, readonly) GLKMatrix4 viewMatrix;
@property (nonatomic, readonly) GLKMatrix4 projectionMatrix;

+ (instancetype)cameraWithFieldOfView:(float)fov aspectRatio:(float)aspectRatio nearClipping:(float)near farClipping:(float)far;

@end
