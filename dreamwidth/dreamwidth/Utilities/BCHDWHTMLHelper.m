//
//  BCHDWHTMLHelper.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-06.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWHTMLHelper.h"

#import <UIKit/UIKit.h>
#import <HTMLKit/HTMLKit.h>

#import "BCHDWTheme.h"
#import "BCHDWUserStringHelper.h"
#import "HTMLElement+DreamBalloon.h"
#import "NSString+DreamBalloon.h"
#import "NSAttributedString+DreamBalloon.h"

typedef enum {
    BCHDWHtmlBoldStyle          = 1 << 0,
    BCHDWHtmlItalicStyle        = 1 << 1,
    BCHDWHtmlStrikethroughStyle = 1 << 2,
    BCHDWHtmlAnchor             = 1 << 3
} BCHDWHtmlStyle;


@interface BCHDWStyleAttributes : NSObject

@property (nonatomic, assign) BCHDWHtmlStyle styles;
@property (nonatomic, readonly) NSDictionary* attributes;
@property (nonatomic, readonly) UIFont* font;
@property (nonatomic, assign) NSInteger fontSizeOffset;

-(void) increaseFontSize;
-(void) decreaseFontSize;

@end

@interface BCHDWTextBlock()

@property (nonatomic, strong) NSMutableAttributedString* content;

@end


@implementation BCHDWBlock

@end

@implementation BCHDWImageBlock

-(BOOL) empty {
    return self.imageUrl == nil || self.imageUrl.length == 0;
}

@end

@implementation BCHDWTextBlock

-(instancetype) init {
    if (self = [super init]) {
        self.content = [NSMutableAttributedString new];
    }
    return self;
}

-(NSAttributedString*) text {
    NSAttributedString* result = [self.content attributedSubstringFromRange:NSMakeRange(0, self.content.length)];
    return [result attributedStringByTrimmingCharacters:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(BOOL) empty {
    return self.text.length == 0;
}

@end

@implementation BCHDWStyleAttributes

-(void) increaseFontSize {
    self.fontSizeOffset += 2;
}

-(void) decreaseFontSize {
    self.fontSizeOffset -= 2;
}

-(UIFont*) font {
    UIFont* font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    UIFontDescriptorSymbolicTraits traits = 0;
    if (self.styles & BCHDWHtmlBoldStyle) {
        traits |= UIFontDescriptorTraitBold;
    }
    if (self.styles & BCHDWHtmlItalicStyle) {
        traits |= UIFontDescriptorTraitItalic;
    }
    
    return [UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:traits] size:font.pointSize + self.fontSizeOffset];
}

-(NSDictionary*) attributes {

    NSMutableDictionary* result = [@{ NSFontAttributeName : self.font,
                                     NSForegroundColorAttributeName : [UIColor blackColor]} mutableCopy];
    if (self.styles & BCHDWHtmlAnchor) {
        [result setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
        [result setObject:[BCHDWTheme instance].primaryColor forKey:NSForegroundColorAttributeName];
    }
    
    if (self.styles & BCHDWHtmlStrikethroughStyle) {
        [result setObject:[NSNumber numberWithInteger:NSUnderlinePatternSolid | NSUnderlineStyleSingle] forKey:NSStrikethroughStyleAttributeName];
    }
    
    return [NSDictionary dictionaryWithDictionary:result];
}

@end

@interface BCHDWHTMLHelper()

@property (nonatomic, nonnull, strong) BCHDWStyleAttributes* defaultAttributes;
@property (nonatomic, nonnull, strong) BCHDWUserStringHelper* userformatter;

@end

@implementation BCHDWHTMLHelper

-(instancetype) init {
    if (self = [super init]) {
        self.defaultAttributes = [BCHDWStyleAttributes new];
        self.userformatter = [BCHDWUserStringHelper new];
    }
    return self;
}

- (void) processMarkup:(HTMLElement*) element array:(NSMutableArray<BCHDWBlock*>*) array {
    for (HTMLNode* node = element.firstChild; node != nil; node = node.nextSibling) {
        if ([node isKindOfClass:[HTMLElement class]]) {
            HTMLElement* e = (HTMLElement*) node;
            if (![e.tagName isEqualToString:@"form"]) {
                if ([self isBlockElement:e]) {
                    BCHDWBlock* last = [array lastObject];
                    if (![last isKindOfClass:[BCHDWTextBlock class]] || !last.empty) {
                        [array addObject:[BCHDWTextBlock new]];
                    }
                    self.defaultAttributes = [BCHDWStyleAttributes new];
                }
                
                if ([e.tagName isEqualToString:@"b"] || [e.tagName isEqualToString:@"strong"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles | BCHDWHtmlBoldStyle;
                } else if ([e.tagName isEqualToString:@"i"] || [e.tagName isEqualToString:@"em"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles | BCHDWHtmlItalicStyle;
                } else if ([e.tagName isEqualToString:@"strike"] || [e.tagName isEqualToString:@"s"] || [e.tagName isEqualToString:@"del"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles | BCHDWHtmlStrikethroughStyle;
                } else if ([e.tagName isEqualToString:@"a"] && e.attributes[@"href"] != nil) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles | BCHDWHtmlAnchor;
                } else if ([e.tagName isEqualToString:@"small"]) {
                    [self.defaultAttributes decreaseFontSize];
                }

                if ([e.tagName isEqualToString:@"img"]) {
                    if ([array lastObject].empty) {
                        [array removeObject:[array lastObject]];
                    }
                    BCHDWImageBlock* image = [BCHDWImageBlock new];
                    [self processImage:e image:image];
                    if (!image.empty) {
                        [array addObject:image];
                    }
                    [array addObject:[BCHDWTextBlock new]];
                } else {
                    [self processMarkup:e array:array];
                }

                if ([e.tagName isEqualToString:@"b"] || [e.tagName isEqualToString:@"strong"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles & ~BCHDWHtmlBoldStyle;
                } else if ([e.tagName isEqualToString:@"i"] || [e.tagName isEqualToString:@"em"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles & ~BCHDWHtmlItalicStyle;
                } else if ([e.tagName isEqualToString:@"strike"] || [e.tagName isEqualToString:@"s"] || [e.tagName isEqualToString:@"del"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles & ~BCHDWHtmlStrikethroughStyle;
                } else if ([e.tagName isEqualToString:@"a"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles & ~BCHDWHtmlAnchor;
                } else if ([e.tagName isEqualToString:@"small"]) {
                    [self.defaultAttributes increaseFontSize];
                }

                if ([self isBlockElement:e]) {
                    BCHDWBlock* last = [array lastObject];
                    if (![last isKindOfClass:[BCHDWTextBlock class]] || !last.empty) {
                        [array addObject:[BCHDWTextBlock new]];
                    }
                    self.defaultAttributes = [BCHDWStyleAttributes new];
                }
            }
        } else if ([node isKindOfClass:[HTMLText class]]) {
            BCHDWBlock* block = [array lastObject];
            if (![block isKindOfClass:[BCHDWTextBlock class]]) {
                block = [BCHDWTextBlock new];
                [array addObject:block];
            }
            [self appendTextNode:(HTMLText*) node array:array];
        }
    }
}

-(void) processImage:(HTMLElement*) element image:(BCHDWImageBlock*) image {
    image.imageUrl = element.attributes[@"src"];
}

- (void) appendText:(NSString*) textContent buffer:(NSMutableAttributedString*) string {
    NSRange   searchedRange = NSMakeRange(0, [textContent length]);
    NSString* pattern = @"(?<!\\\\)@[a-zA-Z0-9_]+(?:\\.[a-zA-Z0-9]+)?";
    NSError*  error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    NSArray* matches = [regex matchesInString:textContent options:0 range: searchedRange];
    for (NSTextCheckingResult* match in matches) {
        NSString* matchText = [textContent substringWithRange:match.range];
        
        if (match.range.location > searchedRange.location) {
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:[textContent substringWithRange:NSMakeRange(searchedRange.location, match.range.location - searchedRange.location)] attributes:self.defaultAttributes.attributes]];
        }
        
        UIImage* icon = nil;
        if ([matchText rangeOfString:@"."].location != NSNotFound) {
            NSRange range = [matchText rangeOfString:@"."];
            NSString* site = [matchText substringFromIndex:range.location + 1];
            matchText = [matchText substringToIndex:range.location];
            icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon", site]];
        }
        
        [string appendAttributedString:[self.userformatter userLabel:[matchText substringFromIndex:1] icon:icon font:self.defaultAttributes.font]];
        searchedRange = NSMakeRange(match.range.location + match.range.length, textContent.length - (match.range.location + match.range.length));
    }
    
    if (searchedRange.length > 0) {
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[textContent substringWithRange:searchedRange] attributes:self.defaultAttributes.attributes]];
    }
}

-(void) appendTextNode:(HTMLText*) text array:(NSMutableArray<BCHDWBlock*>*) array {
    NSString* textContent = text.textContent;
    if (text.parentElement.isBlockElement && (text.previousSibling == nil)) {
        NSCharacterSet* set = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
        NSRange range = [textContent rangeOfCharacterFromSet:set];
        if (range.location != NSNotFound && range.location > 0) {
            textContent = [textContent substringFromIndex:range.location];
        } else if (range.location == NSNotFound) {
            textContent = @"";
        }
    }

    NSArray* paragraphs = [textContent componentsSeparatedByString:@"\n\n"];
    BOOL first = YES;
    for (NSString* paragraph in paragraphs) {
        if ([paragraph stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
            if (!first) {
                [array addObject:[BCHDWTextBlock new]];
            }
            [self appendText:paragraph buffer:((BCHDWTextBlock*) array.lastObject).content];
            first = NO;
        }
    }
}


-(BOOL) isBlockElement:(HTMLElement*) element {
    NSArray* blockTags = @[ @"p", @"div", @"blockquote", @"ol", @"li", @"ul", @"h1", @"h2", @"h3", @"h4", @"h5", @"h6", @"section", @"table", @"pre", @"hr" ];
    return [blockTags containsObject:element.tagName];
}


-(NSArray*) parseHtmlIntoAttributedStrings:(NSString*) html {
    NSMutableArray* result = [NSMutableArray new];
    if ([html isHTMLMarkupPresent] || [html isUserReferencePresent]) {
    
        [result addObject:[BCHDWTextBlock new]];

        HTMLElement* documentBody = [[HTMLDocument documentWithString:html] querySelector:@"body"];
        
        [self processMarkup:documentBody array:result];
        
        while (result.count > 0) {
            BCHDWBlock* last = [result lastObject];
            if (last.empty) {
                [result removeLastObject];
            } else {
                break;
            }
        }
        
    } else {
        BCHDWTextBlock* textBlock = [BCHDWTextBlock new];
        [textBlock.content appendAttributedString:[[NSAttributedString alloc] initWithString:[html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] attributes:self.defaultAttributes.attributes]];
        [result addObject:textBlock];
    }
    return [NSArray arrayWithArray:result];
}

@end
