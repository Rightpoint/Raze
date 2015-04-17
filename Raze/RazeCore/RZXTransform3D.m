//
//  RZXTransform3D.m
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXTransform3D.h>

@implementation RZXTransform3D {
    GLKMatrix4 *_cachedModelMatrix;
}

#pragma mark - lifecycle

+ (instancetype)transform
{
    return [[[self class] alloc] init];
}

+ (instancetype)transformWithTranslation:(GLKVector3)trans rotation:(GLKQuaternion)rot scale:(GLKVector3)scale
{
    return [[[self class] alloc] initWithTranslation:trans rotation:rot scale:scale];
}

- (instancetype)init
{
    return [self initWithTranslation:GLKVector3Make(0.0f, 0.0f, 0.0f) rotation:GLKQuaternionIdentity scale:GLKVector3Make(1.0f, 1.0f, 1.0f)];
}

- (void)dealloc
{
    [self invalidateModelMatrixCache];
}

#pragma mark - public methods

- (BOOL)isEqual:(id)object
{
    BOOL equal = NO;

    if ( self == object ) {
        equal = YES;
    }
    else if ( [object isKindOfClass:[RZXTransform3D class]] ) {
        GLKMatrix4 otherModelMatrix = [(RZXTransform3D *)object modelMatrix];

        if ( memcmp(self.modelMatrix.m, otherModelMatrix.m, sizeof(otherModelMatrix.m)) == 0 ) {
            equal = YES;
        }
    }

    return equal;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p T:{%.4f, %.4f, %.4f}, R:{%.4f, %.4f, %.4f, %.4f}, S:{%.4f, %.4f, %.4f}>", NSStringFromClass([self class]), self, _translation.x, _translation.y, _translation.z, _rotation.x, _rotation.y, _rotation.z, _rotation.w, _scale.x, _scale.y, _scale.z];
}

- (GLKMatrix4)modelMatrix
{
    @synchronized (self) {
        if ( _cachedModelMatrix == NULL ) {
            GLKMatrix4 scale = GLKMatrix4MakeScale(_scale.x, _scale.y, _scale.z);
            GLKMatrix4 rotation = GLKMatrix4MakeWithQuaternion(_rotation);
            
            GLKMatrix4 mat = GLKMatrix4Multiply(rotation, scale);
            
            mat.m[12] += _translation.x;
            mat.m[13] += _translation.y;
            mat.m[14] += _translation.z;
            
            _cachedModelMatrix = (GLKMatrix4 *)malloc(sizeof(GLKMatrix4));
            memcpy(_cachedModelMatrix, &mat, sizeof(GLKMatrix4));
        }
        
        return *_cachedModelMatrix;
    }
}

- (void)setTranslation:(GLKVector3)translation
{
    _translation = translation;
    [self invalidateModelMatrixCache];
}

- (void)setScale:(GLKVector3)scale
{
    _scale = scale;
    [self invalidateModelMatrixCache];
}

- (void)setRotation:(GLKQuaternion)rotation
{
    _rotation = rotation;
    [self invalidateModelMatrixCache];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    RZXTransform3D *copy = [[[self class] alloc] init];
    
    copy.translation = _translation;
    copy.rotation = _rotation;
    copy.scale = _scale;
    
    return copy;
}

#pragma mark - private methods

- (instancetype)initWithTranslation:(GLKVector3)trans rotation:(GLKQuaternion)rot scale:(GLKVector3)scale
{
    self = [super init];
    if ( self ) {
        _translation = trans;
        _rotation = rot;
        _scale = scale;
        
        _cachedModelMatrix = NULL;
    }
    return self;
}

- (void)invalidateModelMatrixCache
{
    @synchronized (self) {
        free(_cachedModelMatrix);
        _cachedModelMatrix = NULL;
    }
}

@end
