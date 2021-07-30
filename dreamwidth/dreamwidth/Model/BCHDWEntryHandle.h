//
//  BCHDWEntryOld.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-06-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BCHDWEntrySummarizer.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWEntryHandle : NSObject

@property (nonatomic, nullable, readonly) NSString* entryId;
@property (nonatomic, nullable, strong) NSString* url;
@property (nonatomic, nullable, strong) NSString* title;
@property (nonatomic, nullable, strong) NSDate* creationDate;
@property (nonatomic, nullable, strong) NSDate* updateDate;
@property (nonatomic, nullable, strong) NSNumber* commentCount;
@property (nonatomic, nullable, strong) NSString* author;
@property (nonatomic, nullable, strong) NSString* communityName;
@property (nonatomic, nullable, readonly) NSString* journal;
@property (nonatomic, nullable, strong) BCHDWSummaryExtract* summary;

+(NSArray*) parseMap:(NSDictionary* _Nonnull) map;

@end

NS_ASSUME_NONNULL_END
