//
//  RZXValueProxy.m
//  RazeCore
//
//  Created by Rob Visentin on 6/25/15.
//

#import <GLKit/GLKMathTypes.h>
#import <RazeCore/RZXValueProxy.h>
#import <RazeCore/RZXAnimatable.h>
#import <RazeCore/RZXInterpolationFunction.h>

@implementation NSValue (RZXAnimatable)

+ (RZXInterpolationFunction *)rzx_interpolationFunctionForKey:(NSString *)key
{
    return [RZXInterpolationFunction floatInterpolator];
}

@end

@implementation RZXValueProxy {
    NSValue *_backingValue;
    void *_bytes;

    struct {
        BOOL x:1;
        BOOL y:1;
        BOOL z:1;
        BOOL w:1;
        BOOL s:1;
    } _typeKeys;
}

+ (Class)class
{
    return [NSValue class];
}

- (Class)class
{
    return [_backingValue class];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (RZXInterpolationFunction *)rzx_interpolationFunctionForKey:(NSString *)key
{
    return [NSValue rzx_interpolationFunctionForKey:key];
}

- (instancetype)initWithBytes:(const void *)value objCType:(const char *)type
{
    if ( (self = [self init]) ) {
        _backingValue = [NSValue valueWithBytes:value objCType:type];

        NSUInteger typeSize;
        NSGetSizeAndAlignment(type, &typeSize, NULL);
        _bytes = malloc(typeSize);
        [_backingValue getValue:_bytes];

        BOOL vec2 = strcmp(type, @encode(GLKVector2)) == 0;
        BOOL vec3 = strcmp(type, @encode(GLKVector3)) == 0;
        BOOL vec4 = strcmp(type, @encode(GLKVector4)) == 0;
        BOOL quat = strcmp(type, @encode(GLKQuaternion)) == 0;

        _typeKeys.x = vec2 || vec3 || vec4 || quat;
        _typeKeys.y = _typeKeys.y;
        _typeKeys.z = vec3 || vec4 || quat;
        _typeKeys.w = vec4 || quat;
        _typeKeys.s = quat;

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ( (self = [self init]) ) {
        _backingValue = [aDecoder decodeObjectForKey:@"_backingValue"];

        NSUInteger len;
        const uint8_t *typeKeys = [aDecoder decodeBytesForKey:@"_typeKeys" returnedLength:&len];
        memcpy(&_typeKeys, typeKeys, len);

        const uint8_t *bytes = [aDecoder decodeBytesForKey:@"_bytes" returnedLength:&len];
        _bytes = malloc(len);
        memcpy(_bytes, bytes, len);
    }
    return self;
}

- (void)dealloc
{
    free(_bytes);
}

- (id)valueForKey:(NSString *)key
{
    id value = nil;

    size_t offset = ~0ul;

    if ( _typeKeys.s && [key isEqualToString:@"s"] ) {
        offset = offsetof(GLKQuaternion, s);
    }
    else if ( _typeKeys.w && [key isEqualToString:@"w"] ) {
        offset = offsetof(GLKVector4, w);
    }
    else if ( _typeKeys.z && [key isEqualToString:@"z"] ) {
        offset = offsetof(GLKVector4, z);
    }
    else if ( _typeKeys.y && [key isEqualToString:@"y"] ) {
        offset = offsetof(GLKVector4, y);
    }
    else if ( _typeKeys.x && [key isEqualToString:@"x"] ) {
        offset = offsetof(GLKVector4, x);
    }

    if ( offset != ~0ul ) {
        float floatVal = *(float *)((char *)_bytes + offset);
        value = [NSNumber numberWithFloat:floatVal];
    }
    else {
        value = [super valueForKey:key];
    }

    return value;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    size_t offset = ~0ul;

    if ( [value isKindOfClass:[NSNumber class]] ) {
        if ( _typeKeys.s && [key isEqualToString:@"s"] ) {
            offset = offsetof(GLKQuaternion, s);
        }
        else if ( _typeKeys.w && [key isEqualToString:@"w"] ) {
            offset = offsetof(GLKVector4, w);
        }
        else if ( _typeKeys.z && [key isEqualToString:@"z"] ) {
            offset = offsetof(GLKVector4, z);
        }
        else if ( _typeKeys.y && [key isEqualToString:@"y"] ) {
            offset = offsetof(GLKVector4, y);
        }
        else if ( _typeKeys.x && [key isEqualToString:@"x"] ) {
            offset = offsetof(GLKVector4, x);
        }
    }

    if ( offset != ~0ul ) {
        float *floatVal = (float *)((char *)_bytes + offset);
        *floatVal = [value floatValue];

        _backingValue = [NSValue valueWithBytes:_bytes objCType:_backingValue.objCType];

        [self.proxyOwner setValue:_backingValue forKey:self.proxiedKey];
    }
    else {
        [super setValue:value forKey:key];
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    RZXValueProxy *copy = [[RZXValueProxy alloc] init];
    copy->_backingValue = _backingValue;
    copy->_typeKeys = _typeKeys;
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_backingValue forKey:@"_backingValue"];
    [aCoder encodeBytes:(const uint8_t *)&_typeKeys length:sizeof(_typeKeys) forKey:@"_typeKeys"];

    NSUInteger typeSize;
    NSGetSizeAndAlignment(_backingValue.objCType, &typeSize, NULL);
    [aCoder encodeBytes:_bytes length:typeSize forKey:@"_bytes"];
}

- (NSString *)description
{
    return [_backingValue description];
}

- (NSString *)debugDescription
{
    return [_backingValue debugDescription];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _backingValue;
}

@end
