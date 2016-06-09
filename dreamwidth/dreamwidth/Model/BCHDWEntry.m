//
//  BCHDWEntry.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-09.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntry.h"

@implementation BCHDWEntry

+(NSArray*) parseMap:(NSDictionary*) map {
    NSMutableArray* result = [NSMutableArray new];
    
    NSInteger count = [[map objectForKey:@"events_count"] integerValue];
    for (NSInteger i = 1; i <= count; i++) {
        BCHDWEntry* entry = [BCHDWEntry new];
        entry.itemId = [map objectForKey:[NSString stringWithFormat:@"events_%ld_itemid", i]];
        entry.subject = [map objectForKey:[NSString stringWithFormat:@"events_%ld_subject", i]];
        [result addObject:entry];
    }
    
    return [NSArray arrayWithArray:result];
}

@end
