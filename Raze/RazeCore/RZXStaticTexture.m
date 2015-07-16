//
//  RZXStaticTexture.m
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <GLKit/GLKTextureLoader.h>
#import <RazeCore/RZXStaticTexture.h>

@implementation RZXStaticTexture {
    BOOL _cacheRequested;
    BOOL _useMipMapping;
}

+ (instancetype)textureWithFileName:(NSString *)fileName useMipMapping:(BOOL)useMipMapping useCache:(BOOL)useCache
{
    return [[self alloc] initWithFileName:fileName useMipMapping:useMipMapping useCache:useCache];
}

#pragma mark - RZXGPUObject overrides

- (BOOL)setupGL
{
    return ([super setupGL] && [self assignIdentifer]);
}

#pragma mark - private methods

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

- (BOOL)assignIdentifer
{
    // TODO: caching

    BOOL assigned = NO;

    NSString *name = [self.fileName stringByDeletingPathExtension];
    NSString *extension = [self.fileName pathExtension];
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:extension];

    if ( path == nil ) {
        NSLog(@"Failed to setup %@: %@ not found in the main bundle.", NSStringFromClass([self class]), self.fileName);
    }
    else {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObject:@(YES) forKey:GLKTextureLoaderOriginBottomLeft];

        if (_useMipMapping) {
            [options setObject:@(YES) forKey:GLKTextureLoaderGenerateMipmaps];
        }

        // GLKTextureLoader will throw a random error if an OpenGL error exists prior to texture loading.
        // This appears to be a bug, but a workaround is to flush the error ahead of time.
        RZXGLError();

        NSError *error;
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];

        if ( error != nil ) {
            NSLog(@"Failed to setup %@: %@", NSStringFromClass([self class]), error.localizedDescription);
        }
        else {
            _size.width = textureInfo.width;
            _size.height = textureInfo.height;
            _name = textureInfo.name;

            assigned = YES;
        }
    }

    return assigned;
}

@end
