//
//  BCHDWComment.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-06-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWComment.h"

@interface BCHDWComment ()

@property (nonatomic, strong) NSNumber* liked;

@end

@implementation BCHDWComment

@dynamic avatarUrl, commentId, commentText, author, creationDate, depth, replyTo, subject, entry, orderKey, liked;

-(NSInteger) lastOrderPart {
    if (self.orderKey != nil) {
        if ([self.orderKey rangeOfString:@"."].location != NSNotFound) {
            return [[self.orderKey substringFromIndex:[self.orderKey rangeOfString:@"." options:NSBackwardsSearch].location + 1] integerValue];
        } else {
            return [self.orderKey integerValue];
        }
    } else {
        return 0;
    }
}

-(NSInteger) depthAsInteger {
    return [self.depth integerValue];
}

-(BOOL) isLike {
    return self.liked == nil ? NO : [self.liked boolValue];
}

-(void) setIsLike:(BOOL)isLike {
    self.liked = [NSNumber numberWithBool:isLike];
}

@end
