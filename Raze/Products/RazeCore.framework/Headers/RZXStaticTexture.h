//
//  RZXStaticTexture.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <RazeCore/RZXTexture.h>

@interface RZXStaticTexture : RZXTexture

@property (copy, nonatomic, readonly) NSString *fileName;

+ (instancetype)textureFromFile:(NSString *)fileName usingCache:(BOOL)useCache;
+ (instancetype)mipmappedTextureFromFile:(NSString *)fileName usingCache:(BOOL)useCache;

@end
