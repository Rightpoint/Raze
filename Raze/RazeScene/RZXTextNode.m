//
//  RZXTextNode.m
//  Raze
//
//  Created by Rob Visentin on 6/29/15.
//
//

#import <RazeCore/RZXDynamicTexture.h>
#import <RazeCore/RZXTransform3D.h>
#import <RazeScene/RZXTextNode.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/NSColor.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSAttributedString.h>
#endif

@interface RZXTextNode ()

@property (strong, nonatomic) RZXTransform3D *textTransform;
@property (strong, nonatomic) RZXDynamicTexture *textTexture;

@end

@implementation RZXTextNode {
    BOOL _attributedTextSet;
}

@synthesize attributedText = _attributedText;

+ (instancetype)nodeWithText:(NSString *)text
{
    RZXTextNode *node = [[self alloc] init];
    node.text = text;

    return node;
}

- (instancetype)init
{
    if ( (self = [super init]) ) {
        _textColor = [RZXColor blackColor];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    if ( _text != text && ![_text isEqualToString:text] ) {
        _text = [text copy];
        _textTexture = nil;
        [self invalidateAttributedTextIfNeeded];
    }
}

- (void)setFont:(RZXFont *)font
{
    if ( _font != font && ![_font isEqual:font] ) {
        _font = font;
        _textTexture = nil;
        [self invalidateAttributedTextIfNeeded];
    }
}

- (void)setTextColor:(RZXColor *)textColor
{
    _textColor = textColor;
    [self invalidateAttributedTextIfNeeded];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if ( _attributedText != attributedText && ![_attributedText isEqual:attributedText] ) {
        _attributedText = [attributedText copy];
        _attributedTextSet = (_attributedText != nil);
        _textTexture = nil;
    }
}

- (NSAttributedString *)attributedText
{
    if ( _attributedText == nil ) {
        NSMutableDictionary *attribs = [NSMutableDictionary dictionary];

        if ( _font != nil ) {
            attribs[NSFontAttributeName] = _font;
        }

        attribs[NSForegroundColorAttributeName] = _textColor ?: [UIColor clearColor];

        _attributedText = [[NSAttributedString alloc] initWithString:_text attributes:attribs];
    }

    return _attributedText;
}

- (RZXTexture *)texture
{
    return _textTexture;
}

- (void)setTexture:(RZXTexture *)texture
{
    // no-op. text node manages its own texture internally
}

- (void)rzx_update:(NSTimeInterval)dt
{
    [self updateTextureIfNeeded];

    [super rzx_update:dt];
}

#pragma mark - private methods

- (void)invalidateAttributedTextIfNeeded
{
    if ( !_attributedTextSet ) {
        _attributedText = nil;
    }
}

#if TARGET_OS_IPHONE
- (void)updateTextureIfNeeded
{
    if ( _textTexture == nil  ) {
        NSAttributedString *attributedText = self.attributedText;

        if ( attributedText.length > 0 ) {
            // TODO: determine constraining sizes and handle word wrapping
            CGRect textRect = [attributedText boundingRectWithSize:CGSizeMake(HUGE_VALF, HUGE_VALF) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];

            textRect.size.width = ceil(textRect.size.width);
            textRect.size.height = ceil(textRect.size.height);

            _textTexture = [RZXDynamicTexture textureWithSize:textRect.size scale:[UIScreen mainScreen].scale];

            [_textTexture updateWithBlock:^(RZXTexture *self, CGContextRef ctx) {
                UIGraphicsPushContext(ctx);
                [attributedText drawAtPoint:CGPointZero];
                UIGraphicsPopContext();
            }];
        }
    }
}
#else
// TODO
#endif

@end
