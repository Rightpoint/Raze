//
//  RZXStaticTexture.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <RazeCore/RZXTexture.h>

/**
 *  A texture whose contents are not expected to be updated frequently, as in the case of most models.
 */
@interface RZXStaticTexture : RZXTexture

@property (copy, nonatomic, readonly) NSString *fileName;

/**
 *  Load a texture from a file
 *
 *  @param fileName file name
 *  @param useCache if true, then the texture will be loaded from the cache if it exists and stored into the cache if it does not exist.
 *
 *  @return static texture instance
 */
+ (instancetype)textureFromFile:(NSString *)fileName usingCache:(BOOL)useCache;

/**
 *  Load a texture from a file and also generate mipmaps of the texture. Mipmaps will be automatically utlized by Raze and will maintain texture clarity when using a large texture that appears on a small object (or an object that will at times be far away and appear small).
 *
 *  @param fileName file name
 *  @param useCache if true, then the texture will be loaded from the cache if it exists and stored into the cache if it does not exist.
 *
 *  @return static texture instance
 */
+ (instancetype)mipmappedTextureFromFile:(NSString *)fileName usingCache:(BOOL)useCache;

@end
