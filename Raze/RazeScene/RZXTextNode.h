//
//  RZXTextNode.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <RazeCore/RZXBase.h>
#import <RazeScene/RZXModelNode.h>

typedef NS_ENUM(NSUInteger, RZXHorizontalAlignment) {
    kRZXHorizontalAlignmentCenter,
    kRZXHorizontalAlignmentLeft,
    kRZXHorizontalAlignmentRight
};

typedef NS_ENUM(NSUInteger, RZXVerticalAlignment) {
    kRZXVerticalAlignmentCenter,
    kRZXVerticalAlignmentTop,
    kRZXVerticalAlignmentBottom
};

@class RZXFont;
@class RZXColor;

@interface RZXTextNode : RZXModelNode

@property (copy, nonatomic) NSString *text;

@property (strong, nonatomic) RZXFont *font;
@property (strong, nonatomic) RZXColor *textColor;

@property (copy, nonatomic) NSAttributedString *attributedText;

@property (assign, nonatomic) RZXHorizontalAlignment horizontalAlignment;
@property (assign, nonatomic) RZXVerticalAlignment verticalAlignment;

+ (instancetype)nodeWithText:(NSString *)text;

@end
