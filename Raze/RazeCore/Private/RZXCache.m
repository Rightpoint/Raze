//
//  RZXCache.m
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import "RZXCache.h"

@interface RZXCache ()

@property (strong, nonatomic) NSMutableDictionary *cachedObjects;
@property (strong, nonatomic) NSMutableDictionary *referenceCounts;
@property (strong, nonatomic) dispatch_queue_t cacheQueue;

@end

@implementation RZXCache

#pragma mark - lifecycle

- (instancetype)init
{
    if ( (self = [super init]) ) {
        _cachedObjects = [NSMutableDictionary dictionary];
        _referenceCounts = [NSMutableDictionary dictionary];

        const char *queueLabel = [NSString stringWithFormat:@"com.raze.cache-%lu", (unsigned long)self.hash].UTF8String;
        _cacheQueue = dispatch_queue_create(queueLabel, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - public methods

- (void)cacheObject:(id)object forKey:(id<NSCopying>)key
{
    if ( object != nil ) {
        __weak typeof(self) wself = self;
        dispatch_async(self.cacheQueue, ^{
            __strong typeof(wself) sself = wself;
            sself.cachedObjects[key] = object;
            [sself retainObjectImmediatelyForKey:key];
        });
    }
}

- (void)retainObjectForKey:(id<NSCopying>)key
{
    __weak typeof(self) wself = self;
    dispatch_async(self.cacheQueue, ^{
        __strong typeof(wself) sself = wself;
        [sself retainObjectImmediatelyForKey:key];
    });
}

- (void)releaseObjectForKey:(id<NSCopying>)key
{
    __weak typeof(self) wself = self;
    dispatch_async(self.cacheQueue, ^{
        __strong typeof(wself) sself = wself;
        [sself releaseObjectImmediatelyForKey:key];
    });
}

- (id)objectForKey:(id<NSCopying>)key
{
    __block id object = nil;

    if ( key != nil ) {
        dispatch_sync(self.cacheQueue, ^{
            object = self.cachedObjects[key];
        });
    }

    return object;
}

- (void)removeObjectForKey:(id<NSCopying>)key
{
    __weak typeof(self) wself = self;
    dispatch_async(self.cacheQueue, ^{
        __strong typeof(wself) sself = wself;
        [sself.cachedObjects removeObjectForKey:key];
        [sself.referenceCounts removeObjectForKey:key];
    });
}

- (void)removeAllObjects
{
    __weak typeof(self) wself = self;
    dispatch_async(self.cacheQueue, ^{
        __strong typeof(wself) sself = wself;
        [sself.cachedObjects removeAllObjects];
        [sself.referenceCounts removeAllObjects];
    });
}

#pragma mark - private methods

- (void)retainObjectImmediatelyForKey:(id<NSCopying>)key
{
    NSNumber *refCount = self.referenceCounts[key];

    if ( refCount == nil ) {
        self.referenceCounts[key] = @(1);
    }
    else {
        self.referenceCounts[key] = @(refCount.intValue + 1);
    }
}

- (void)releaseObjectImmediatelyForKey:(id<NSCopying>)key
{
    int refCount = [self.referenceCounts[key] intValue];

    if ( refCount <= 1 ) {
        [self.referenceCounts removeObjectForKey:key];
        [self.cachedObjects removeObjectForKey:key];
    }
    else {
        self.referenceCounts[key] = @(refCount - 1);
    }
}

@end

@implementation RZXCache (RZXSubscripting)

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    if ( obj != nil ) {
        [self cacheObject:obj forKey:key];
    }
    else {
        [self removeObjectForKey:key];
    }
}

@end
