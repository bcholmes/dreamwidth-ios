//
//  BCHDWComment.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-06-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "BCHDWEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWComment : NSManagedObject

@property (nonatomic, strong) NSString* author;
@property (nonatomic, strong) NSNumber* depth;
@property (nonatomic, strong) NSString* commentId;
@property (nonatomic, strong) NSString* commentText;
@property (nonatomic, strong) NSString* avatarUrl;
@property (nonatomic, strong) BCHDWComment* replyTo;
@property (nonatomic, strong) NSString* subject;
@property (nonatomic, strong) NSDate* creationDate;
@property (nonatomic, strong) BCHDWEntry* entry;
@property (nonatomic, strong) NSString* orderKey;

@property (nonatomic, readonly) NSInteger lastOrderPart;
@property (nonatomic, readonly) NSInteger depthAsInteger;
@property (nonatomic, assign) BOOL isLike;

@end

NS_ASSUME_NONNULL_END
