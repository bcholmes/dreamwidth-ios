//
//  BCHDWMenuOption.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWMenuOption.h"

@implementation BCHDWMenuOption

WS_ENUM(BCHDWMenuOption, ENTRIES)
WS_ENUM(BCHDWMenuOption, PROFILE)

-(NSString*) text {
    NSString* words = [self.name stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    return [words capitalizedString];
}

@end
