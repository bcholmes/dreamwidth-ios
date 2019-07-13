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

#import "BCHDWUserStringHelper.h"

typedef enum {
    BCHDWHtmlBoldStyle          = 1 << 0,
    BCHDWHtmlItalicStyle        = 1 << 1,
    BCHDWHtmlStrikethroughStyle = 1 << 2
} BCHDWHtmlStyle;


@interface BCHDWStyleAttributes : NSObject

@property (nonatomic, assign) BCHDWHtmlStyle styles;
@property (nonatomic, readonly) NSDictionary* attributes;
@property (nonatomic, readonly) UIFont* font;

@end

@implementation BCHDWBlock

@end


@implementation BCHDWStyleAttributes

-(UIFont*) font {
    UIFont* font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    UIFontDescriptorSymbolicTraits traits = 0;
    if (self.styles & BCHDWHtmlBoldStyle) {
        traits |= UIFontDescriptorTraitBold;
    }
    if (self.styles & BCHDWHtmlItalicStyle) {
        traits |= UIFontDescriptorTraitItalic;
    }
    
    return [UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:traits] size:font.pointSize];
}

-(NSDictionary*) attributes {

    if (self.styles & BCHDWHtmlStrikethroughStyle) {
        return @{ NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlinePatternSolid | NSUnderlineStyleSingle],
                  NSFontAttributeName : self.font,
                  NSForegroundColorAttributeName : [UIColor blackColor] };
    } else {
        return @{ NSFontAttributeName : self.font,
                  NSForegroundColorAttributeName : [UIColor blackColor]};
    }
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

- (void) processMarkup:(HTMLElement*) element array:(NSMutableArray<NSMutableAttributedString*>*) array {
    
    for (HTMLNode* node in element.childNodes) {
        if ([node isKindOfClass:[HTMLElement class]]) {
            HTMLElement* e = (HTMLElement*) node;
            if (![e.tagName isEqualToString:@"form"]) {
                if ([e.tagName isEqualToString:@"b"] || [e.tagName isEqualToString:@"strong"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles | BCHDWHtmlBoldStyle;
                } else if ([e.tagName isEqualToString:@"i"] || [e.tagName isEqualToString:@"em"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles | BCHDWHtmlItalicStyle;
                } else if ([e.tagName isEqualToString:@"strike"] || [e.tagName isEqualToString:@"s"] || [e.tagName isEqualToString:@"del"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles | BCHDWHtmlStrikethroughStyle;
                }

                [self processMarkup:e array:array];

                if ([e.tagName isEqualToString:@"b"] || [e.tagName isEqualToString:@"strong"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles & ~BCHDWHtmlBoldStyle;
                } else if ([e.tagName isEqualToString:@"i"] || [e.tagName isEqualToString:@"em"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles & ~BCHDWHtmlItalicStyle;
                } else if ([e.tagName isEqualToString:@"strike"] || [e.tagName isEqualToString:@"s"] || [e.tagName isEqualToString:@"del"]) {
                    self.defaultAttributes.styles = self.defaultAttributes.styles & ~BCHDWHtmlStrikethroughStyle;
                }

                if ([self isBlockElement:e]) {
                    if ([array lastObject].length > 0) {
                        NSMutableAttributedString* string = [NSMutableAttributedString new];
                        [array addObject:string];
                    }
                    self.defaultAttributes = [BCHDWStyleAttributes new];
                }
            }
        } else if ([node isKindOfClass:[HTMLText class]]) {
            [self appendText:(HTMLText*) node buffer:[array lastObject]];
        }
    }
}

-(void) appendText:(HTMLText*) text buffer:(NSMutableAttributedString*) string {
    NSString* textContent = text.textContent;
    
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


-(BOOL) isBlockElement:(HTMLElement*) element {
    NSArray* blockTags = @[ @"p", @"div", @"blockquote", @"ol", @"li", @"ul", @"h1", @"h2", @"h3", @"h4", @"h5", @"h6", @"section", @"table", @"pre", @"hr" ];
    return [blockTags containsObject:element.tagName];
}


-(NSArray*) parseHtmlIntoAttributedStrings:(NSString*) html {
    NSMutableArray* result = [NSMutableArray new];
    NSMutableAttributedString* string = [NSMutableAttributedString new];
    [result addObject:string];

    HTMLElement* documentBody = [[HTMLDocument documentWithString:html] querySelector:@"body"];
    
    [self processMarkup:documentBody array:result];
    
    while (result.count > 0) {
        NSMutableAttributedString* last = [result lastObject];
        if (last.length == 0) {
            [result removeLastObject];
        } else {
            break;
        }
    }
    
    
    return [NSArray arrayWithArray:result];
}

@end
