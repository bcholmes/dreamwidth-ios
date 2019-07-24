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

@dynamic author, entryId, entryText, subject, creationDate, updateDate, url, avatarUrl, rating, numberOfComments, lockedFlag, summaryText, summaryText2, summaryImageUrl;

-(BOOL) locked {
    return [self.lockedFlag boolValue];
}

-(void) setLocked:(BOOL) locked {
    self.lockedFlag = [NSNumber numberWithBool:locked];
}

-(BCHDWEntryHandle*) handle {
    BCHDWEntryHandle* result = [BCHDWEntryHandle new];
    result.url = self.url;
    result.author = self.author;
    result.creationDate = self.creationDate;
    result.updateDate = self.updateDate;
    result.commentCount = self.numberOfComments;
    return result;
}

@end
