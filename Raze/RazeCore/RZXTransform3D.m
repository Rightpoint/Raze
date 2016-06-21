//
//  RZXTransform3D.m
//
//  Created by Rob Visentin on 1/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXTransform3D.h>
#import <RazeCore/RZXMath.h>
#import <RazeCore/NSValue+RZXExtensions.h>

@implementation RZXTransform3D {
    GLKMatrix4 *_cachedModelMatrix;
}

#pragma mark - lifecycle

+ (instancetype)transform
{
    return [[self alloc] init];
}

+ (instancetype)transformWithTranslation:(GLKVector3)trans
{
    return [[self alloc] initWithTranslation:trans];
}

+ (instancetype)transformWithRotation:(GLKQuaternion)rot
{
    return [[self alloc] initWithRotation:rot];
}

+ (instancetype)transformWithScale:(GLKVector3)scale
{
    return [[self alloc] initWithScale:scale];
}

+ (instancetype)transformWithTranslation:(GLKVector3)trans rotation:(GLKQuaternion)rot scale:(GLKVector3)scale
{
    return [[[self class] alloc] initWithTranslation:trans rotation:rot scale:scale];
}

- (instancetype)init
{
    return [self initWithTranslation:RZXVector3Zero rotation:GLKQuaternionIdentity scale:RZXVector3One];
}

- (instancetype)initWithTranslation:(GLKVector3)trans
{
    return [self initWithTranslation:trans rotation:GLKQuaternionIdentity scale:RZXVector3One];
}

- (instancetype)initWithRotation:(GLKQuaternion)rot
{
    return [self initWithTranslation:RZXVector3Zero rotation:rot scale:RZXVector3One];
}

- (instancetype)initWithScale:(GLKVector3)scale
{
    return [self initWithTranslation:RZXVector3Zero rotation:GLKQuaternionIdentity scale:scale];
}

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
    _rotation = GLKQuaternionNormalize(rotation);
    RZXQuaternionGetEulerAngles(rotation, &_eulerAngles.x, &_eulerAngles.y, &_eulerAngles.z);

    [self invalidateModelMatrixCache];
}

- (void)setEulerAngles:(GLKVector3)eulerAngles
{
    _eulerAngles = eulerAngles;
    _rotation = RZXQuaternionMakeEuler(eulerAngles.x, eulerAngles.y, eulerAngles.z);

    [self invalidateModelMatrixCache];
}

- (void)translateXBy:(float)dx
{
    _translation.x += dx;
    [self invalidateModelMatrixCache];
}

- (void)translateYBy:(float)dy
{
    _translation.y += dy;
    [self invalidateModelMatrixCache];
}

- (void)translateZBy:(float)dz
{
    _translation.z += dz;
    [self invalidateModelMatrixCache];
}

- (void)translateXTo:(float)tx
{
    _translation.x = tx;
    [self invalidateModelMatrixCache];
}

- (void)translateYTo:(float)ty
{
    _translation.y = ty;
    [self invalidateModelMatrixCache];
}

- (void)translateZTo:(float)tz
{
    _translation.z = tz;
    [self invalidateModelMatrixCache];
}

- (void)translateBy:(GLKVector3)translation
{
    self.translation = GLKVector3Add(_translation, translation);
}

- (void)scaleXBy:(float)dx
{
    _scale.x *= dx;
    [self invalidateModelMatrixCache];
}

- (void)scaleYBy:(float)dy
{
    _scale.y *= dy;
    [self invalidateModelMatrixCache];
}

- (void)scaleZBy:(float)dz
{
    _scale.z *= dz;
    [self invalidateModelMatrixCache];
}

- (void)scaleBy:(GLKVector3)scale
{
    self.scale = GLKVector3Multiply(_scale, scale);
}

- (void)scaleXTo:(float)sx
{
    _scale.x = sx;
    [self invalidateModelMatrixCache];
}

- (void)scaleYTo:(float)sy
{
    _scale.y = sy;
    [self invalidateModelMatrixCache];
}

- (void)scaleZTo:(float)sz
{
    _scale.z = sz;
    [self invalidateModelMatrixCache];
}

- (void)rotateXBy:(float)angle
{
    [self rotateXTo:_eulerAngles.x + angle];
}

- (void)rotateYBy:(float)angle
{
    [self rotateYTo:_eulerAngles.y + angle];
}

- (void)rotateZBy:(float)angle
{
    [self rotateZTo:_eulerAngles.z + angle];
}

- (void)rotateBy:(GLKQuaternion)rotation
{
    self.rotation = GLKQuaternionMultiply(_rotation, rotation);
}

- (void)rotateXTo:(float)angle
{
    self.eulerAngles = GLKVector3Make(angle, _eulerAngles.y, _eulerAngles.z);
}

- (void)rotateYTo:(float)angle
{
    self.eulerAngles = GLKVector3Make(_eulerAngles.x, angle, _eulerAngles.z);
}

- (void)rotateZTo:(float)angle
{
    self.eulerAngles = GLKVector3Make(_eulerAngles.x, _eulerAngles.y, angle);
}

- (void)transformBy:(RZXTransform3D *)transform
{
    if ( transform != nil ) {
        _translation = GLKVector3Add(_translation, transform.translation);
        _scale = GLKVector3Multiply(_scale, transform.scale);
        _rotation = GLKQuaternionMultiply(_rotation, transform.rotation);

        [self invalidateModelMatrixCache];
    }
}

- (instancetype)transformedBy:(RZXTransform3D *)transform
{
    RZXTransform3D *transformed = [self copy];
    [transformed transformBy:transform];

    return transformed;
}

- (void)invert
{
    _translation = GLKVector3Negate(_translation);
    _scale = GLKVector3Make(1.0 / _scale.x, 1.0 / _scale.y, 1.0 / _scale.z);
    _rotation = GLKQuaternionInvert(_rotation);

    [self invalidateModelMatrixCache];
}

- (RZXTransform3D *)invertedTransform
{
    RZXTransform3D *inverted = [self copy];
    [inverted invert];

    return inverted;
}

- (GLKVector3)transformPoint:(GLKVector3)point
{
    return RZXMatrix4TransformVector3(self.modelMatrix, point);
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

- (void)invalidateModelMatrixCache
{
    @synchronized (self) {
        free(_cachedModelMatrix);
        _cachedModelMatrix = NULL;
    }
}

@end
