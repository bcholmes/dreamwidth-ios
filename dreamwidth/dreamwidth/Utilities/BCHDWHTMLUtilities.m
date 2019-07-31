//
//  HTMLUtilities.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-31.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWHTMLUtilities.h"

@implementation BCHDWHTMLUtilities

+(BOOL) isExcluded:(HTMLElement*) element {
    if (([element.tagName isEqualToString:@"div"]) && element.attributes[@"class"] != nil && [element.attributes[@"class"] rangeOfString:@"edittime"].location != NSNotFound) {
        return YES;
    } else if ([element.tagName isEqualToString:@"form"]) {
        return YES;
    } else {
        return NO;
    }
}

+(BOOL) isUserReference:(HTMLElement*) element {
    return [element.tagName isEqualToString:@"span"] && [element.attributes[@"class"] isEqualToString:@"ljuser"];
}


@end
