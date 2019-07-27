//
//  BCHDWEntry.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-09.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BCHDWEntryHandle.h"

@interface BCHDWEntry : NSManagedObject

@property (nonatomic, strong) NSString* author;
@property (nonatomic, strong) NSString* community;
@property (nonatomic, strong) NSString* rating;
@property (nonatomic, strong) NSString* entryId;
@property (nonatomic, strong) NSString* subject;
@property (nonatomic, strong) NSString* entryText;
@property (nonatomic, strong) NSString* summaryText;
@property (nonatomic, strong) NSString* summaryText2;
@property (nonatomic, strong) NSString* summaryImageUrl;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* avatarUrl;
@property (nonatomic, strong) NSDate* creationDate;
@property (nonatomic, strong) NSDate* updateDate;
@property (nonatomic, strong) NSDate* lastActivityDate;
@property (nonatomic, strong) NSNumber* numberOfComments;
@property (nonatomic, assign) BOOL locked;
@property (nonatomic, readonly) BCHDWEntryHandle* handle;
@end
