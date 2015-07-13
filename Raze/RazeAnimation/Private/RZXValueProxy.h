//
//  RZXValueProxy.h
//  RazeCore
//
//  Created by Rob Visentin on 6/25/15.
//

#import <Foundation/Foundation.h>

@interface RZXValueProxy : NSObject <NSCopying, NSSecureCoding>

@property (weak, nonatomic) id proxyOwner;
@property (copy, nonatomic) NSString *proxiedKey;

- (instancetype)initWithBytes:(const void *)value objCType:(const char *)type;

@end
