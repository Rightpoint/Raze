//
//  RZXTextNode.h
//  RazeCore
//
//  Created by Rob Visentin on 6/29/15.
//

#import <RazeCore/RZXBase.h>
#import <RazeScene/RZXModelNode.h>

#if TARGET_OS_IPHONE
#import <UIKit/NSParagraphStyle.h>
#else
#import <AppKit/NSParagraphStyle.h>
#endif

typedef NS_ENUM(NSUInteger, RZXHorizontalAlignment) {
    RZXHorizontalAlignmentCenter,
    RZXHorizontalAlignmentLeft,
    RZXHorizontalAlignmentRight
};

typedef NS_ENUM(NSUInteger, RZXVerticalAlignment) {
    RZXVerticalAlignmentCenter,
    RZXVerticalAlignmentTop,
    RZXVerticalAlignmentBottom
};

@class RZXFont;
@class RZXColor;

@interface RZXTextNode : RZXModelNode

@property (copy, nonatomic) NSString *text;

@property (strong, nonatomic) RZXFont *font;
@property (strong, nonatomic) RZXColor *textColor;

@property (assign, nonatomic) NSLineBreakMode lineBreakMode;
@property (assign, nonatomic) NSTextAlignment textAlignment;

@property (copy, nonatomic) NSAttributedString *attributedText;

@property (assign, nonatomic) RZXHorizontalAlignment horizontalAlignment;
@property (assign, nonatomic) RZXVerticalAlignment verticalAlignment;

// TODO: this is currently specified in screen points. Ideally this should be in GL units.
@property (assign, nonatomic) CGSize boundingSize;

+ (instancetype)nodeWithText:(NSString *)text;

@end
