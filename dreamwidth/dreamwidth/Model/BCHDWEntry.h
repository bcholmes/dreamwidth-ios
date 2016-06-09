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
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* pictureKeyword;
@property (nonatomic, strong) NSString* tags;
@property (nonatomic, strong) NSString* poster;

+(NSArray*) parseMap:(NSDictionary*) map user:(NSString*) user;

@end
