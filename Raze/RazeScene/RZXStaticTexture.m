//
//  RZXTexture.m
//  Raze
//
//  Created by John Stricker on 6/17/15.
//
//

#import <GLKit/GLKit.h>
#import <RazeCore/RZXGLContext.h>

#import "RZXStaticTexture.h"

@implementation RZXStaticTexture {
    GLuint _identifier;
    
    BOOL _cacheRequested;
    BOOL _useMipMapping;
}

+ (instancetype)textureWithFileName:(NSString *)fileName useMipMapping:(BOOL)useMipMapping useCache:(BOOL)useCache
{
    return [[self alloc] initWithFileName:fileName useMipMapping:useMipMapping useCache:useCache];
}

+ (void)deleteAllTexturesFromCache
{
    NSMutableDictionary *cache = [self cachedTextureIdentifiers];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    for (NSString *key in cache) {
        [keys addObject:key];
    }
    
    for (NSString *key in keys) {
        GLuint textureID = [cache[key] unsignedIntValue];
        glDeleteTextures(1, &textureID);
    }
    
    [cache removeAllObjects];
}

#pragma mark - RZXOpenGLObject

- (void)rzx_setupGL
{
    [self assignIdentifer];
}

- (void)rzx_bindGL
{
    [RZXGLContext currentContext].activeTexture = GL_TEXTURE0;
    glBindTexture(GL_TEXTURE_2D, _identifier);
}

- (void)rzx_teardownGL
{
    glDeleteTextures(1, &_identifier);
    
    if (_cacheRequested) {
        NSMutableDictionary *cache = [RZXStaticTexture cachedTextureIdentifiers];
        [cache removeObjectForKey:_fileName];
    }
}

#pragma mark - private methods

+ (NSNumber *)cachedTextureIndexForKey:(NSString *)keyString
{
    NSMutableDictionary *cache = [RZXStaticTexture cachedTextureIdentifiers];
    return cache[keyString];
}

+ (NSMutableDictionary *)cachedTextureIdentifiers
{
    static NSMutableDictionary *cacheDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheDictionary = [[NSMutableDictionary alloc] init];
    });
    return cacheDictionary;
}

- (instancetype)initWithFileName:(NSString *)fileName useMipMapping:(BOOL)useMipMapping useCache:(BOOL)useCache
{
    self = [super init];
    if (self) {
        _fileName = fileName;
        _cacheRequested = useCache;
        _useMipMapping = useMipMapping;
    }
    return self;
}

- (void)assignIdentifer
{
    if (!_cacheRequested) {
        _identifier = [self createNewTextureWithFileName:_fileName];
    }
    else {
        NSMutableDictionary *cache = [RZXStaticTexture cachedTextureIdentifiers];
        if ( cache[_fileName] != nil ) {
            _identifier = [cache[_fileName] unsignedIntValue];
        }
        else {
            _identifier = [self createNewTextureWithFileName:_fileName];
            cache[_fileName] = @(_identifier);
        }
    }
}

- (GLuint)createNewTextureWithFileName:(NSString *)fileName
{
    NSString *name = [fileName stringByDeletingPathExtension];
    NSString *extension = [fileName pathExtension];
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:extension];

    if ( path == nil ) {
        NSLog(@"error, text file not found: %@",fileName);
    }
    
    NSMutableDictionary *options= [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft];
    if (_useMipMapping) {
        [options setObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderGenerateMipmaps];
    }
    NSError *error;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    
    if ( error != nil ) {
        NSLog(@"error loading texture: %@", error);
        return 0;
    }
    else {
        return textureInfo.name;
    }
}

@end
