//
//  RZXCompositeEffect.h
//
//  Created by Rob Visentin on 1/16/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeCore/RZXEffect.h>

@interface RZXCompositeEffect : RZXEffect

@property (strong, nonatomic, readonly) RZXEffect *firstEffect;
@property (strong, nonatomic, readonly) RZXEffect *secondEffect;

@property (strong, nonatomic, readonly) RZXEffect *currentEffect;

+ (instancetype)compositeEffectWithFirstEffect:(RZXEffect *)first secondEffect:(RZXEffect *)second;

@end
