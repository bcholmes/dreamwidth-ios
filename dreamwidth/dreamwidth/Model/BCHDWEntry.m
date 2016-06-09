//
//  BCHDWEntry.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-09.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntry.h"

@implementation BCHDWEntry

+(NSArray*) parseMap:(NSDictionary*) map user:(NSString*) user {
    NSMutableArray* result = [NSMutableArray new];
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    
    NSInteger count = [[map objectForKey:@"events_count"] integerValue];
    for (NSInteger i = 1; i <= count; i++) {
        BCHDWEntry* entry = [BCHDWEntry new];
        entry.itemId = [map objectForKey:[NSString stringWithFormat:@"events_%ld_itemid", i]];
        entry.subject = [map objectForKey:[NSString stringWithFormat:@"events_%ld_subject", i]];
        entry.url = [map objectForKey:[NSString stringWithFormat:@"events_%ld_url", i]];
        NSString* poster = [map objectForKey:[NSString stringWithFormat:@"events_%ld_poster", i]];
        if (poster == nil) {
            entry.poster = user;
        } else {
            entry.poster = poster;
        }
        
        if (entry.itemId != nil) {
            [dictionary setObject:entry forKey:entry.itemId];
        }
        [result addObject:entry];
    }

    NSInteger propCount = [[map objectForKey:@"prop_count"] integerValue];
    for (NSInteger i = 1; i <= propCount; i++) {
        NSString* name = [map objectForKey:[NSString stringWithFormat:@"prop_%ld_name", i]];
        NSString* value = [map objectForKey:[NSString stringWithFormat:@"prop_%ld_value", i]];
        NSString* itemId = [map objectForKey:[NSString stringWithFormat:@"prop_%ld_itemid", i]];
        BCHDWEntry* entry = [dictionary objectForKey:itemId];
        if ([name isEqualToString:@"taglist"]) {
            entry.tags = value;
        } else if ([name isEqualToString:@"picture_keyword"]) {
            entry.pictureKeyword = value;
        }

    }

    return [NSArray arrayWithArray:result];
}

@end
