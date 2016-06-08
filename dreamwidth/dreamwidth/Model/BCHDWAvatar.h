//
//  BCHDWAvatar.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-08.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCHDWAvatar : NSObject

@property (nonatomic, strong) NSString* keywords;
@property (nonatomic, strong) NSString* url;

+(NSArray*) parseMap:(NSDictionary*) map;

@end
