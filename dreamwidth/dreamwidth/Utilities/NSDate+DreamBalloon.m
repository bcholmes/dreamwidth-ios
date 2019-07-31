//
//  NSDate+DreamBalloon.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "NSDate+DreamBalloon.h"

#import <DateTools/NSDate+DateTools.h>

@implementation NSDate (DreamBalloon)

-(NSString*) relativeDate {
    if ([self isInFuture]) {
        return [self formattedDateWithFormat:@"MMM d"];
    } else {
        return [self timeAgoSinceNow];
    }
}

-(BOOL) isInFuture {
    return [self isLaterThan:[NSDate date]];
}

@end
