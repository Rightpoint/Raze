//
//  RZXStaticTexture.m
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <GLKit/GLKTextureLoader.h>
#import <RazeCore/RZXStaticTexture.h>
#import <RazeCore/RZXCache.h>

@interface RZXStaticTexture ()

@property (assign, nonatomic) BOOL usingCache;
@property (assign, nonatomic) BOOL usingMipmapping;

@end

@implementation RZXStaticTexture

+ (instancetype)textureFromFile:(NSString *)fileName usingCache:(BOOL)useCache
{
    return [[self alloc] initWithFileName:fileName useMipMapping:NO useCache:useCache];
}

+ (instancetype)mipmappedTextureFromFile:(NSString *)fileName usingCache:(BOOL)useCache
{
    return [[self alloc] initWithFileName:fileName useMipMapping:YES useCache:useCache];
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
        _usingCache = useCache;
        _usingMipmapping = useMipMapping;
    }
    return self;
}

- (BOOL)assignIdentifer
{
    BOOL assigned = NO;

    RZXCache *cache = self.usingCache ? [self.configuredContext cacheForClass:[RZXStaticTexture class]] : nil;

    GLKTextureInfo *cachedTextureInfo = [cache objectForKey:self.fileName];

    if ( cachedTextureInfo != nil ) {
        [cache retainObjectForKey:self.fileName];
        [self applyTextureInfo:cachedTextureInfo];

        assigned = YES;
    }
    else {
        NSString *name = [self.fileName stringByDeletingPathExtension];
        NSString *extension = [self.fileName pathExtension];
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:extension];

        if ( path == nil ) {
            NSLog(@"Failed to setup %@: %@ not found in the main bundle.", NSStringFromClass([self class]), self.fileName);
        }
        else {
            NSDictionary *options = @{ GLKTextureLoaderOriginBottomLeft : @(YES),
                                       GLKTextureLoaderGenerateMipmaps : @(_usingMipmapping) };

            // GLKTextureLoader will throw a random error if an OpenGL error exists prior to texture loading.
            // This appears to be a bug, but a workaround is to flush the error ahead of time.
            RZXGLError();

            NSError *error;
            GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];

            if ( error != nil ) {
                NSLog(@"Failed to setup %@: %@", NSStringFromClass([self class]), error.localizedDescription);
            }
            else {
                [self applyTextureInfo:textureInfo];

                if ( self.usingCache ) {
                    [cache cacheObject:textureInfo forKey:self.fileName];
                }
                
                assigned = YES;
            }
        }
    }

    return assigned;
}

- (void)applyTextureInfo:(GLKTextureInfo *)textureInfo
{
    _size.width = textureInfo.width;
    _size.height = textureInfo.height;
    _name = textureInfo.name;
}

@end
