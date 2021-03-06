//
//  RZXBlurEffect.h
//
//  Created by Rob Visentin on 1/16/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <RazeEffects/RZXEffect.h>

/**
 *  Blur 2D Effect
 */
@interface RZXBlurEffect : RZXEffect

@property (assign, nonatomic) GLfloat sigma;

+ (instancetype)effectWithSigma:(GLfloat)sigma;

@end
