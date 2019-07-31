//
//  BCHDWEntrySummarizer.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntrySummarizer.h"

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
    }
}

@end


@implementation BCHDWEntrySummarizer

@end
