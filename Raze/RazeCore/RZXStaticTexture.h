//
//  RZXStaticTexture.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <RazeCore/RZXTexture.h>

@interface RZXStaticTexture : RZXTexture

@property (copy, readonly, nonatomic) NSString *fileName;

+ (instancetype)textureWithFileName:(NSString *)fileName useMipMapping:(BOOL)useMipMapping useCache:(BOOL)useCache;
+ (void)deleteAllTexturesFromCache;

@end
