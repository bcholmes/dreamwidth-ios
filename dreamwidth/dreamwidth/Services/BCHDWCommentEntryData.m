//
//  BCHDWCommentEntryData.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-11.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWCommentEntryData.h"

@implementation BCHDWCommentEntryData

-(NSDictionary*) formProperties {
    NSMutableDictionary* result = [NSMutableDictionary new];
    
    if (self.commentText != nil) {
        [result setObject:self.commentText forKey:@"body"];
    }
    if (self.subject != nil) {
        [result setObject:self.subject forKey:@"subject"];
    }
    
    return [NSDictionary dictionaryWithDictionary:result];
}

@end
