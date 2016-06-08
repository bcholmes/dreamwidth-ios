//
//  BCHDWAvatar.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-08.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWAvatar.h"

@implementation BCHDWAvatar

+(NSArray*) parseMap:(NSDictionary*) map {
    NSMutableArray* result = [NSMutableArray new];
    NSInteger count = [[map objectForKey:@"pickw_count"] integerValue];
    for (NSInteger i = 1; i <= count; i++) {
        BCHDWAvatar* avatar = [BCHDWAvatar new];
        avatar.keywords = [map objectForKey:[NSString stringWithFormat:@"pickw_%ld", i]];
    }
    
    return [NSArray arrayWithArray:result];
}

@end
