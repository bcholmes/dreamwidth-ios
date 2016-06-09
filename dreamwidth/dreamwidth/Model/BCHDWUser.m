//
//  BCHDWUser.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-08.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWUser.h"

@implementation BCHDWUser

+(BCHDWUser*) parseMap:(NSDictionary*) map {
    BCHDWUser* result = [BCHDWUser new];
    result.name = [map objectForKey:@"name"];
    result.avatars = [BCHDWAvatar parseMap:map];
    return result;
}

-(BCHDWAvatar*) avatarByKeyword:(NSString*) keyword {
    BCHDWAvatar* result = nil;
    for (BCHDWAvatar* avatar in self.avatars) {
        if ([avatar.keywords isEqualToString:keyword]) {
            result = avatar;
            break;
        }
    }
    return result;
}

@end
