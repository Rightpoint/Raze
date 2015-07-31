//
//  RZXTextNode.m
//  RazeScene
//
//  Created by Rob Visentin on 6/29/15.
//

#import <RazeCore/RZXDynamicTexture.h>
#import <RazeCore/RZXTransform3D.h>
#import <RazeCore/RZXQuadMesh.h>
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
        _lineBreakMode = NSLineBreakByWordWrapping;
        _textAlignment = NSTextAlignmentLeft;
        _textTransform = [RZXTransform3D transform];
        _boundingSize = CGSizeMake(HUGE_VALF, HUGE_VALF);

        self.mesh = [RZXQuadMesh quad];
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

        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = self.lineBreakMode;
        paragraphStyle.alignment = self.textAlignment;

        attribs[NSParagraphStyleAttributeName] = paragraphStyle;

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

- (GLKMatrix4)modelMatrix
{
    return GLKMatrix4Multiply([super modelMatrix], self.textTransform.modelMatrix);
}

- (BOOL)bindGL
{
    [self updateTextureIfNeeded];

    // TODO: use better conversion from points -> OpenGL coords
    CGRect viewport = [RZXGLContext currentContext].viewport;
    CGSize texSize = self.textTexture.size;
    CGFloat texScale = self.textTexture.scale;

    CGFloat aspectRatio = texSize.width / texSize.height;

    float xScale = texSize.width * texScale / viewport.size.width;
    float yScale = texSize.height * texScale / viewport.size.height;

    if ( xScale < yScale ) {
        self.textTransform.scale = GLKVector3Make(xScale, xScale / aspectRatio, 1.0f);
    }
    else {
        self.textTransform.scale = GLKVector3Make(aspectRatio * yScale, yScale, 1.0f);
    }

    return [super bindGL];
}

- (void)rzx_render
{
    // TODO: make this part of the context
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    [super rzx_render];
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
            CGRect textRect = [attributedText boundingRectWithSize:self.boundingSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];

            textRect.size.width = ceil(textRect.size.width);
            textRect.size.height = ceil(textRect.size.height);

            _textTexture = [RZXDynamicTexture textureWithSize:textRect.size scale:[UIScreen mainScreen].scale];
            [_textTexture setupGL];

            [_textTexture applyOptions:@{ kRZXTextureMinFilterKey : @(GL_LINEAR),
                                          kRZXTextureSWrapKey : @(GL_CLAMP_TO_EDGE),
                                          kRZXTextureTWrapKey : @(GL_CLAMP_TO_EDGE) }];

            [_textTexture updateWithBlock:^(RZXTexture *self, CGContextRef ctx) {
                CGRect contextRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);

                [attributedText drawWithRect:contextRect options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
            }];
        }
    }
}
#else
// TODO
#endif

@end
