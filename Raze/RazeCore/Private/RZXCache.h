//
//  RZXCache.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <Foundation/Foundation.h>

@interface RZXCache : NSObject

- (void)cacheObject:(id)object forKey:(id<NSCopying>)key;

// These are not "true" -retain, -release calls, but rather used for the cache's
// own internal reference count.
- (void)retainObjectForKey:(id<NSCopying>)key;
- (void)releaseObjectForKey:(id<NSCopying>)key;

- (id)objectForKey:(id<NSCopying>)key;

- (void)removeObjectForKey:(id<NSCopying>)key;
- (void)removeAllObjects;

@end
