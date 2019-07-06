//
//  NSString+DreamBalloon.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-06.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "NSString+DreamBalloon.h"

@implementation NSString (DreamBalloon)

-(BOOL) isHTMLMarkupPresent {
    NSError* error = nil;
    NSRange range = NSMakeRange(0, self.length);
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:0 error:&error];
    NSArray* matches = [regex matchesInString:self options:0 range:range];
    if (error == nil && matches.count > 0) {
        return YES;
    } else {
        regex = [NSRegularExpression regularExpressionWithPattern:@"&([a-z0-9]+|#[0-9]{1,6}|#x[0-9a-f]{1,6});" options:0 error:&error];
        matches = [regex matchesInString:self options:0 range:range];
        return error == nil && matches.count > 0;
    }
}

@end
