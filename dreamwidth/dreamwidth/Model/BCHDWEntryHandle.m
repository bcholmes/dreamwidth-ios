//
//  BCHDWEntryHandle.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-06-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntryHandle.h"

@implementation BCHDWEntryHandle

+(NSArray*) parseMap:(NSDictionary*) map {
    NSMutableArray* result = [NSMutableArray new];
    
    NSInteger count = [[map objectForKey:@"events_count"] integerValue];
    for (NSInteger i = 1; i <= count; i++) {
        BCHDWEntryHandle* entry = [BCHDWEntryHandle new];
        entry.url = [map objectForKey:[NSString stringWithFormat:@"events_%ld_url", i]];
        [result addObject:entry];
    }
    
    return [NSArray arrayWithArray:result];
}

-(NSString*) journal {
    if (self.communityName) {
        return self.communityName;
    } else {
        return self.author;
    }
}
@end
