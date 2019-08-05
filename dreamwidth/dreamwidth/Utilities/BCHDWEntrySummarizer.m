//
//  BCHDWEntrySummarizer.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntrySummarizer.h"

#import "BCHDWHTMLUtilities.h"
#import "HTMLElement+DreamBalloon.h"

@implementation BCHDWSummaryExtract

-(instancetype) init {
    if (self = [super init]) {
        self.summaryText1 = [NSMutableString new];
        self.summaryText2 = [NSMutableString new];
    }
    return self;
}

-(NSMutableString*) currentText {
    if (self.summaryImageUrl != nil && self.summaryImageUrl.length > 0) {
        return self.summaryText2;
    } else {
        return self.summaryText1;
    }
}

-(BOOL) isMaxLength {
    NSUInteger maxLength = 60;
    NSError* error = nil;
    NSRange range = NSMakeRange(0, self.summaryText1.length);
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:&error];
    NSArray* matches = [regex matchesInString:self.summaryText1 options:0 range:range];
    
    if (matches.count > maxLength) {
        NSTextCheckingResult* match = matches[maxLength-1];
        [self.summaryText1 deleteCharactersInRange:NSMakeRange(match.range.location, self.summaryText1.length - match.range.location)];
        [self.summaryText1 appendString:@"..."];
        return YES;
    } else {
        maxLength -= matches.count;
        range = NSMakeRange(0, self.summaryText2.length);
        if (maxLength > 0) {
            regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:&error];
            matches = [regex matchesInString:self.summaryText2 options:0 range:range];
            if (matches.count > maxLength) {
                NSTextCheckingResult* match = matches[maxLength-1];
                [self.summaryText2 deleteCharactersInRange:NSMakeRange(match.range.location, self.summaryText2.length - match.range.location)];
                [self.summaryText2 appendString:@"..."];
                return YES;
            } else {
                return NO;
            }
        } else {
            [self.summaryText2 deleteCharactersInRange:range];
            return YES;
        }
    }
}

@end


@implementation BCHDWEntrySummarizer

-(BCHDWSummaryExtract*) collectSummaryExtract:(HTMLElement*) content {
    BCHDWSummaryExtract* result = [BCHDWSummaryExtract new];
    [self collectSummaryExtract:content buffer:result];
    return result;
}


-(BOOL) collectSummaryExtract:(HTMLElement*) content buffer:(BCHDWSummaryExtract*) extract {
    BOOL stop = NO;
    for (HTMLNode* node = content.firstChild; node != nil; node = node.nextSibling) {
        if ([node isKindOfClass:[HTMLElement class]]) {
            HTMLElement* element = (HTMLElement*) node;
            if ([element.tagName isEqualToString:@"br"]) {
                [extract.currentText appendString:@"\n"];
            } else if ([BCHDWHTMLUtilities isExcluded:element]) {
                // skip it
            } else if ([self isFakeCommentCountMechanism:element]) {
                stop = YES;
                break;
            } else if ([self isCut:element]) {
                [extract.currentText appendString:node.textContent];
                stop = YES;
                break;
            } else if ([BCHDWHTMLUtilities isUserReference:element]) {
                [extract.currentText appendString:node.textContent];
            } else if ([element.tagName isEqualToString:@"img"]) {
                if (extract.summaryImageUrl != nil && extract.summaryImageUrl.length > 0) {
                    stop = YES;
                    break;
                } else {
                    extract.summaryImageUrl = element.attributes[@"src"];
                }
            } else {
                if (extract.currentText.length == 0) {
                    // don't do anything
                } else if ([element.tagName isEqualToString:@"p"] || element.isHeader) {
                    NSString* trimmed = [extract.currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [extract.currentText replaceCharactersInRange:NSMakeRange(0, extract.currentText.length) withString:trimmed];
                    [extract.currentText appendString:@"\n\n"];
                } else if (element.isBlockElement) {
                    [extract.currentText appendString:@"\n"];
                }
                stop = [self collectSummaryExtract:element buffer:extract];
                if (stop) {
                    break;
                }
            }
        } else if ([node isKindOfClass:[HTMLText class]]) {
            [extract.currentText appendString:node.textContent];
            if ([extract isMaxLength]) {
                stop = YES;
                break;
            }
        }
    }
    return stop;
}

-(BOOL) isCut:(HTMLElement*) element {
    return [element.tagName isEqualToString:@"a"] && ((element.attributes[@"name"] != nil && [element.attributes[@"name"] rangeOfString:@"cutid"].location == 0) || (element.attributes[@"href"] != nil && [element.attributes[@"href"] rangeOfString:@"#cutid"].location != NSNotFound));
}

-(BOOL) isFakeCommentCountMechanism:(HTMLElement*) element {
    return [element.tagName isEqualToString:@"img"] && element.attributes[@"src"] != nil && [element.attributes[@"src"] rangeOfString:@"https://www.dreamwidth.org/tools/commentcount"].location != NSNotFound;
}

@end
