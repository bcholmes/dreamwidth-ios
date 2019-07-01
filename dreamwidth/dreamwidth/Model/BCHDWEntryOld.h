//
//  BCHDWEntryOld.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-06-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWEntryOld : NSObject
@property (nonatomic, strong) NSString* itemId;
@property (nonatomic, strong) NSString* subject;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* pictureKeyword;
@property (nonatomic, strong) NSString* tags;
@property (nonatomic, strong) NSString* poster;

+(NSArray*) parseMap:(NSDictionary*) map user:(NSString*) user;

@end

NS_ASSUME_NONNULL_END
