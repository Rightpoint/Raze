//
//  RZXAnimatable.m
//  RazeCore
//
//  Created by Rob Visentin on 6/24/15.
//

#import <objc/runtime.h>
#import <GLKit/GLKMathTypes.h>
#import <RazeCore/RZXAnimatable.h>
#import <RazeCore/RZXInterpolationFunction.h>
#import <RazeCore/RZXValueProxy.h>

#pragma mark - private interface

@interface RZXObjcProperty : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *typeEncoding;
@property (nonatomic, readonly) NSUInteger typeSize;

@property (nonatomic, readonly) BOOL isGLKType;

@property (nonatomic, readonly) SEL getter;
@property (nonatomic, readonly) SEL setter;

@property (nonatomic, readonly) NSMethodSignature *getterMethodSig;
@property (nonatomic, readonly) NSMethodSignature *setterMethodSig;

+ (instancetype)propertyWithObjCProperty:(objc_property_t)prop ofClass:(Class)class;

@end

@interface NSObject (RZXProperties)

+ (NSDictionary *)rzx_propertiesByKey;
+ (RZXObjcProperty *)rzx_propertyForKey:(NSString *)key;

@end

static inline id rzx_valueForGLKProperty(id self, RZXObjcProperty *p)
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:p.getterMethodSig];
    invocation.selector = p.getter;

    [invocation invokeWithTarget:self];

    void *ret = malloc(p.typeSize);
    [invocation getReturnValue:ret];

    RZXValueProxy *wrappedVal = [[RZXValueProxy alloc] initWithBytes:ret objCType:p.typeEncoding.UTF8String];

    wrappedVal.proxyOwner = self;
    wrappedVal.proxiedKey = p.name;

    free(ret);

    return wrappedVal;
}

static inline void rzx_setValueForGLKProperty(id self, id value, RZXObjcProperty *p)
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:p.setterMethodSig];
    invocation.selector = p.setter;

    void *bytes = malloc(p.typeSize);
    [value getValue:bytes];

    [invocation setArgument:bytes atIndex:2];
    [invocation invokeWithTarget:self];

    free(bytes);
}

@implementation NSObject (RZXAnimatable)

+ (void)rzx_addKVCComplianceForGLKTypes
{
    @synchronized (self) {
        if ( [objc_getAssociatedObject(self, _cmd) boolValue] ) {
            return;
        }

        objc_setAssociatedObject(self, _cmd, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        Method valueForKey = class_getInstanceMethod(self, @selector(valueForKey:));
        Method setValueForKey = class_getInstanceMethod(self, @selector(setValue:forKey:));

        IMP valueForKeyImp = method_getImplementation(valueForKey);
        class_replaceMethod(self, method_getName(valueForKey), imp_implementationWithBlock(^id (id self, NSString *key) {
            id value = nil;
            RZXObjcProperty *prop = [[self class] rzx_propertyForKey:key];

            if ( prop.isGLKType ) {
                value = rzx_valueForGLKProperty(self, prop);
            }
            else {
                value = ((id(*)(id, SEL, NSString*))valueForKeyImp)(self, @selector(valueForKey:), key);
            }

            return value;
        }), method_getTypeEncoding(valueForKey));

        IMP setValueForKeyImp = method_getImplementation(setValueForKey);
        class_replaceMethod(self, method_getName(setValueForKey), imp_implementationWithBlock(^void (id self, id value, NSString *key) {
            RZXObjcProperty *prop = [[self class] rzx_propertyForKey:key];

            if ( prop.isGLKType && prop.setter != NULL ) {
                rzx_setValueForGLKProperty(self, value, prop);
            }
            else {
                ((void(*)(id, SEL, id, NSString*))setValueForKeyImp)(self, @selector(setValue:forKey:), value, key);
            }
        }), method_getTypeEncoding(setValueForKey));
    }
}

+ (RZXInterpolationFunction *)rzx_interpolationFunctionForKey:(NSString *)key
{
    RZXInterpolationFunction *function = nil;

    RZXObjcProperty *property = [self rzx_propertyForKey:key];

    if ( property != nil ) {
        const char *encoding = property.typeEncoding.UTF8String;

        if ( strcmp(encoding, @encode(float)) == 0 ||
            strcmp(encoding, @encode(double)) == 0 ) {
            function = [RZXInterpolationFunction floatInterpolator];
        }
        else if ( property.typeSize == sizeof(GLKVector2) ) {
            function = [RZXInterpolationFunction vec2Interpolator];
        }
        else if ( property.typeSize == sizeof(GLKVector3) ) {
            function = [RZXInterpolationFunction vec3Interpolator];
        }
        else if ( strcmp(encoding, @encode(GLKVector4)) == 0 ) {
            function = [RZXInterpolationFunction vec4Interpolator];
        }
        else if ( strcmp(encoding, @encode(GLKQuaternion)) == 0 ) {
            function = [RZXInterpolationFunction quaternionInterpolator];
        }
    }

    return function;
}

@end

#pragma mark - private implementations

@implementation NSObject (RZXProperties)

+ (void)rzx_loadProperties
{
    @synchronized (self) {
        if ( [objc_getAssociatedObject(self, _cmd) boolValue] ) {
            return;
        }

        objc_setAssociatedObject(self, _cmd, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    NSMutableDictionary *propertiesByKey = [NSMutableDictionary dictionary];

    unsigned int n;
    objc_property_t *properties = class_copyPropertyList(self, &n);

    for ( unsigned int i = 0; i < n; i++ ) {
        RZXObjcProperty *property = [RZXObjcProperty propertyWithObjCProperty:properties[i] ofClass:self];

        if ( property != nil ) {
            propertiesByKey[property.name] = property;
        }
    }

    free(properties);

    objc_setAssociatedObject(self, @selector(rzx_propertiesByKey), propertiesByKey, OBJC_ASSOCIATION_COPY);
}

+ (NSDictionary *)rzx_propertiesByKey
{
    [self rzx_loadProperties];

    return objc_getAssociatedObject(self, _cmd);
}

+ (RZXObjcProperty *)rzx_propertyForKey:(NSString *)key
{
    RZXObjcProperty *property = nil;

    for ( Class cls = self; property == nil && cls != nil; cls = class_getSuperclass(cls) ) {
        property = [cls rzx_propertiesByKey][key];
    }

    return property;
}

@end

@implementation RZXObjcProperty

+ (instancetype)propertyWithObjCProperty:(objc_property_t)prop ofClass:(__unsafe_unretained Class)class
{
    RZXObjcProperty *property = [[RZXObjcProperty alloc] init];

    const char *name = property_getName(prop);

    if ( name != NULL ) {
        property->_name = [NSString stringWithUTF8String:name];
    }

    const char *attributes = property_getAttributes(prop);

    char *delim = strchr(attributes, ',');

    const char *start = attributes + 1;
    size_t len = delim != NULL ? (size_t)(delim - start) : strlen(attributes);

    char *encoding = (char *)malloc(len + 1);
    memcpy(encoding, start, len);
    encoding[len] = '\0';

    property->_typeEncoding = [NSString stringWithUTF8String:encoding];
    NSGetSizeAndAlignment(encoding, &property->_typeSize, NULL);

    NSString *glkPrefix = [NSString stringWithFormat:@"%c_GLK", _C_UNION_B];
    property->_isGLKType = [property.typeEncoding hasPrefix:glkPrefix];

    free(encoding);

    const char *getterPtr = strstr(attributes, ",G");

    if ( getterPtr != NULL ) {
        property->_getter = [self selectorAt:getterPtr + 2];
    }
    else {
        property->_getter = NSSelectorFromString(property.name);
    }

    if ( strstr(attributes, ",R") == NULL ) {
        const char *setterPtr = strstr(attributes, ",S");

        if ( setterPtr != NULL ) {
            property->_setter = [self selectorAt:setterPtr + 2];
        }
        else {
            NSString *capName = [[property.name substringToIndex:1] uppercaseString];

            if ( property.name.length > 0 ) {
                capName = [capName stringByAppendingString:[property.name substringFromIndex:1]];
            }

            property->_setter = NSSelectorFromString([NSString stringWithFormat:@"set%@:", capName]);
        }
    }

    NSString *typeSig = nil;
    if ( property.isGLKType ) {
        NSMutableString *sig = [NSMutableString stringWithFormat:@"%c?=", _C_STRUCT_B];
        for ( NSUInteger i = 0; i < property.typeSize; i += sizeof(float) ) {
            [sig appendFormat:@"%c", _C_FLT];
        }

        [sig appendFormat:@"%c%s%s", _C_STRUCT_E, @encode(id), @encode(SEL)];

        typeSig = sig;
    }
    else {
        typeSig = [NSString stringWithFormat:@"%s%s%s", property.typeEncoding.UTF8String, @encode(id), @encode(SEL)];
    }

    property->_getterMethodSig = [NSMethodSignature signatureWithObjCTypes:typeSig.UTF8String];

    if ( property.setter != NULL ) {
        if ( property.isGLKType ) {
            NSMutableString *sig = [NSMutableString stringWithFormat:@"%s%s%s%c?=", @encode(void), @encode(id), @encode(SEL), _C_STRUCT_B];

            for ( NSUInteger i = 0; i < property.typeSize; i += sizeof(float) ) {
                [sig appendFormat:@"%c", _C_FLT];
            }

            [sig appendFormat:@"%c", _C_STRUCT_E];

            typeSig = sig;
        }
        else {
            typeSig = [NSString stringWithFormat:@"%s%s%s%s", @encode(void), @encode(id), @encode(SEL), property.typeEncoding.UTF8String];
        }

        property->_setterMethodSig = [NSMethodSignature signatureWithObjCTypes:typeSig.UTF8String];
    }

    return property;
}

+ (SEL)selectorAt:(const char *)start
{
    SEL selector = NULL;

    if ( start != NULL ) {
        char *delim = strchr(start, ',');

        if ( delim == NULL ) {
            selector = sel_getUid(start);
        }
        else {
            size_t len = (size_t)(delim - start);

            char *selStr = malloc(len + 1);
            memcpy(selStr, start, len);
            selStr[len] = '\0';

            selector = sel_getUid(selStr);

            free(selStr);
        }
    }

    return selector;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@, T:%@, G:%@, S:%@>", self.name, self.typeEncoding, NSStringFromSelector(self.getter), NSStringFromSelector(self.setter)];
}

@end