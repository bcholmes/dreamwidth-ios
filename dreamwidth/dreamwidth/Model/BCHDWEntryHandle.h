//
//  BCHDWEntryOld.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-06-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWEntryHandle : NSObject

@property (nonatomic, nullable, strong) NSString* url;

+(NSArray*) parseMap:(NSDictionary* _Nonnull) map;

@end

NS_ASSUME_NONNULL_END
