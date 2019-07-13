//
//  BCHDWCommentEntryData.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-11.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BCHDWAvatar.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWCommentEntryData : NSObject

@property (nonatomic, nullable, strong) NSString* subject;
@property (nonatomic, nullable, strong) NSString* commentText;
@property (nonatomic, nullable, strong) BCHDWAvatar* avatar;

@property (nonatomic, nullable, readonly) NSDictionary* formProperties;

@end

NS_ASSUME_NONNULL_END
