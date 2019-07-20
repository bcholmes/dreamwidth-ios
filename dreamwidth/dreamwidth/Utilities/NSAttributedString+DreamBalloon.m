//
//  NSAttributedString+DreamBalloon.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-19.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "NSAttributedString+DreamBalloon.h"

@implementation NSAttributedString (DreamBalloon)

-(NSAttributedString*) attributedStringByTrimmingCharacters:(NSCharacterSet*) set {
    NSMutableAttributedString* temp = [self mutableCopy];
    [temp trimCharacters:set];
    return [[NSAttributedString alloc] initWithAttributedString:temp];
}

@end

@implementation NSMutableAttributedString (DreamBalloon)

-(void) trimCharacters:(NSCharacterSet*) set {
    NSRange range = [[self string] rangeOfCharacterFromSet:set];
    
    while (range.length != 0 && range.location == 0) {
        [self replaceCharactersInRange:range withString:@""];
        range = [[self string] rangeOfCharacterFromSet:set];
    }

    range = [[self string] rangeOfCharacterFromSet:set options:NSBackwardsSearch];
    
    while (range.length != 0 && NSMaxRange(range) == self.length) {
        [self replaceCharactersInRange:range withString:@""];
        range = [[self string] rangeOfCharacterFromSet:set options:NSBackwardsSearch];
    }
}

@end
