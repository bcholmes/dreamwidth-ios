//
//  BCHDWUser.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-08.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCHDWUser : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSArray* avatars;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* encodedPassword;

+(BCHDWUser*) parseMap:(NSDictionary*) map;

@end
