//
//  RZXCamera.m
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXCamera.h>

@implementation RZXCamera {
    GLKMatrix4 *_cachedProjectionMatrix;
}

+ (instancetype)cameraWithFieldOfView:(float)fov aspectRatio:(float)aspectRatio nearClipping:(float)near farClipping:(float)far
{
    return [[[self class] alloc] initWithFieldOfView:fov aspectRatio:aspectRatio nearClipping:near farClipping:far];
}

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        _up = GLKVector3Make(0.0f, 1.0f, 0.0f);
    }
    return self;
}

- (void)dealloc
{
    [self invalidateProjectionMatrixCache];
}

- (RZXTransform3D *)transform
{
    if ( _transform == nil ) {
        _transform = [RZXTransform3D transform];
    }
    return _transform;
}

- (void)setUp:(GLKVector3)up
{
    _up = GLKVector3Normalize(up);
}

- (void)setFieldOfView:(float)fieldOfView
{
    _fieldOfView = fieldOfView;
    [self invalidateProjectionMatrixCache];
}

- (void)setAspectRatio:(float)aspectRatio
{
    _aspectRatio = aspectRatio;
    [self invalidateProjectionMatrixCache];
}

- (void)setNear:(float)near
{
    _near = near;
    [self invalidateProjectionMatrixCache];
}

- (void)setFar:(float)far
{
    _far = far;
    [self invalidateProjectionMatrixCache];
}

- (GLKMatrix4)projectionMatrix
{
    @synchronized (self ) {
        if ( _cachedProjectionMatrix == NULL ) {
            GLKMatrix4 proj = GLKMatrix4MakePerspective(_fieldOfView, _aspectRatio, _near, _far);
            
            _cachedProjectionMatrix = (GLKMatrix4 *)malloc(sizeof(GLKMatrix4));
            memcpy(_cachedProjectionMatrix, &proj, sizeof(GLKMatrix4));
        }
        
        return *_cachedProjectionMatrix;
    }
}

- (GLKMatrix4)viewMatrix
{
    GLKMatrix4 camWorldMatrix = self.transform.modelMatrix;
    
    GLKVector4 forward = GLKVector4Make(_up.x, _up.z, -_up.y, 1);
    GLKVector4 to4 = GLKMatrix4MultiplyVector4(camWorldMatrix, forward);
    
    GLKVector3 to = GLKVector3Make(to4.x, to4.y, to4.z);
    GLKVector3 from = GLKVector3Make(camWorldMatrix.m[12], camWorldMatrix.m[13], camWorldMatrix.m[14]);
    GLKVector3 up = GLKMatrix4MultiplyVector3(camWorldMatrix, _up);
    
    GLKVector3 zAxis = GLKVector3Normalize(GLKVector3Subtract(from, to));
    GLKVector3 xAxis = GLKVector3Normalize(GLKVector3CrossProduct(up, zAxis));
    GLKVector3 yAxis = GLKVector3Normalize(GLKVector3CrossProduct(zAxis, xAxis));
    
    float tx = -GLKVector3DotProduct(xAxis, from);
    float ty = -GLKVector3DotProduct(yAxis, from);
    float tz = -GLKVector3DotProduct(zAxis, from);
    
    GLKMatrix4 m;
    
    m.m00 = xAxis.x;    m.m01 = yAxis.x;    m.m02 = zAxis.x;    m.m03 = 0;
    m.m10 = xAxis.y;    m.m11 = yAxis.y;    m.m12 = zAxis.y;    m.m13 = 0;
    m.m20 = xAxis.z;    m.m21 = yAxis.z;    m.m22 = zAxis.z;    m.m23 = 0;
    m.m30 = tx;         m.m31 = ty;         m.m32 = tz;         m.m33 = 1;
    
    return m;
}

#pragma mark - private methods

- (instancetype)initWithFieldOfView:(float)fov aspectRatio:(float)aspectRatio nearClipping:(float)near farClipping:(float)far
{
    self = [self init];
    if ( self ) {
        _fieldOfView = fov;
        _aspectRatio = aspectRatio;
        _near = near;
        _far = far;
    }
    return self;
}

- (void)invalidateProjectionMatrixCache
{
    free(_cachedProjectionMatrix);
    _cachedProjectionMatrix = NULL;
}

@end
