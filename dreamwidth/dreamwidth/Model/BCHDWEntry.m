//
//  BCHDWEntry.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-09.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntry.h"

@interface BCHDWEntry()

@property (nonatomic, strong) NSNumber* lockedFlag;

@end

@implementation BCHDWEntry

@dynamic author, entryId, entryText, subject, creationDate, updateDate, url, avatarUrl, rating, numberOfComments, lockedFlag;

-(BOOL) locked {
    return [self.lockedFlag boolValue];
}

-(void) setLocked:(BOOL) locked {
    self.lockedFlag = [NSNumber numberWithBool:locked];
}

@end
