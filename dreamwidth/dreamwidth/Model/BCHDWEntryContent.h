//
//  BCHDWEntryContent.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-08-05.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWEntryContent : NSManagedObject

@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* entryText;
@property (nonatomic, strong) NSDate* lastLoadDate;


@end

NS_ASSUME_NONNULL_END
