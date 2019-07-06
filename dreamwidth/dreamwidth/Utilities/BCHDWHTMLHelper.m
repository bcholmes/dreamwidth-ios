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

typedef enum {
    BCHDWHtmlBoldStyle          = 1 << 0,
    BCHDWHtmlItalicStyle        = 1 << 1,
    BCHDWHtmlStrikethroughStyle = 1 << 2
} BCHDWHtmlStyle;


@interface BCHDWStyleAttributes : NSObject

@property (nonatomic, assign) BCHDWHtmlStyle styles;
@property (nonatomic, readonly) NSDictionary* attributes;

@end

@implementation BCHDWStyleAttributes

-(NSDictionary*) attributes {
    UIFont* font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    UIFontDescriptorSymbolicTraits traits = 0;
    if (self.styles & BCHDWHtmlBoldStyle) {
        traits |= UIFontDescriptorTraitBold;
    }
    if (self.styles & BCHDWHtmlItalicStyle) {
        traits |= UIFontDescriptorTraitItalic;
    }
    
    UIFont* newFont = [UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:traits] size:font.pointSize];

    if (self.styles & BCHDWHtmlStrikethroughStyle) {
        return @{ NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlinePatternSolid | NSUnderlineStyleSingle],
                  NSFontAttributeName : newFont,
                  NSForegroundColorAttributeName : [UIColor blackColor] };
    } else {
        return @{ NSFontAttributeName : newFont,
                  NSForegroundColorAttributeName : [UIColor blackColor]};
    }
}

@end

@interface BCHDWHTMLHelper()

@property (nonatomic, nonnull, strong) BCHDWStyleAttributes* defaultAttributes;

@end

@implementation BCHDWHTMLHelper

-(instancetype) init {
    if (self = [super init]) {
        self.defaultAttributes = [BCHDWStyleAttributes new];
    }
    return self;
}

- (void) processMarkup:(HTMLElement*) element array:(NSMutableArray<NSMutableAttributedString*>*) array {
    
    for (HTMLNode* node in element.childNodes) {
        if ([node isKindOfClass:[HTMLElement class]]) {
            HTMLElement* e = (HTMLElement*) node;
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
                NSMutableAttributedString* string = [NSMutableAttributedString new];
                self.defaultAttributes = [BCHDWStyleAttributes new];
                [array addObject:string];
            }
            
        } else if ([node isKindOfClass:[HTMLText class]]) {
            NSAttributedString* part = [[NSAttributedString alloc] initWithString:node.textContent attributes:self.defaultAttributes.attributes];
            [[array lastObject] appendAttributedString:part];
        }
    }
}

-(BOOL) isBlockElement:(HTMLElement*) element {
    NSArray* blockTags = @[ @"p", @"div", @"blockquote" ];
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
