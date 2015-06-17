//
//  RZXTexture.h
//  Raze
//
//  Created by John Stricker on 6/17/15.
//
//

#import <Foundation/Foundation.h>
#import <RazeCore/RazeCore.h>

@interface RZXTexture : NSObject

@property (assign, readonly, nonatomic) GLuint identifier;
@property (copy, readonly, nonatomic) NSString *fileName;

+ (instancetype)textureWithFileName:(NSString *)fileName useMipMapping:(BOOL)useMipMapping useCache:(BOOL)useCache;

- (void)deleteTexture;

@end
