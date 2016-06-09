//
//  BCHDWEntry.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-09.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCHDWEntry : NSObject

@property (nonatomic, strong) NSString* itemId;
@property (nonatomic, strong) NSString* subject;

+(NSArray*) parseMap:(NSDictionary*) map;

@end
