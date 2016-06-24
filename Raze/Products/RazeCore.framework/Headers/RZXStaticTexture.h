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

// Load texture from a file. If using the cache and this file was loaded previously, then the texture will make use of a previously created OpenGL texture buffer
+ (instancetype)textureFromFile:(NSString *)fileName;

//Load a texture from a file and also generate mipmaps of the texture. If available, Mipmaps will be automatically utlized by Raze and will maintain texture clarity when using a large texture that appears on a small object (or an object that will at times be far away and appear small).
+ (instancetype)mipmappedTextureFromFile:(NSString *)fileName;

@end
