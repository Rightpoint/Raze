//
//  RZXTexture.h
//  Raze
//
//  Created by John Stricker on 6/17/15.
//
//

#import <RazeCore/RZXOpenGLObject.h>

@interface RZXTexture : NSObject <RZXOpenGLObject>

@property (copy, readonly, nonatomic) NSString *fileName;

+ (instancetype)textureWithFileName:(NSString *)fileName useMipMapping:(BOOL)useMipMapping useCache:(BOOL)useCache;
+ (void)deleteAllTexturesFromCache;

@end
