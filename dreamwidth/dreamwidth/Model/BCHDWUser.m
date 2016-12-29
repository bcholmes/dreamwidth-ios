//
//  BCHDWUser.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-08.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWUser.h"

@interface BCHDWUser ()

@property (nonatomic, strong) NSString* defaultAvatarUrl;

@end

@implementation BCHDWUser

+(BCHDWUser*) parseMap:(NSDictionary*) map {
    BCHDWUser* result = [BCHDWUser new];
    result.name = [map objectForKey:@"name"];
    result.avatars = [BCHDWAvatar parseMap:map];
    result.defaultAvatarUrl = [map objectForKey:@"defaultpicurl"];
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

-(BCHDWAvatar*) defaultAvatar {
    BCHDWAvatar* result = nil;
    for (BCHDWAvatar* avatar in self.avatars) {
        if ([avatar.url isEqualToString:self.defaultAvatarUrl]) {
            result = avatar;
            break;
        }
    }
    return result;
}

@end
