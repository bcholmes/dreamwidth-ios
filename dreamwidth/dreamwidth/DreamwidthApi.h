//
//  DreamwidthApi.h
//  dreamwidth
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCHDWUser.h"

typedef NS_ENUM(NSInteger, DWErrorCodes) {
    DWAuthenticationFailedError = 1000
};

#define DWErrorDomain @"org.dreamwidth"


@interface DreamwidthApi : NSObject

@property (nonatomic, strong) BCHDWUser* currentUser;

-(void) loginWithUser:(NSString*) userid password:(NSString*) password andCompletion:(void (^)(NSError* error, BCHDWUser* user)) callback;
-(void) getEvents:(BCHDWUser*) user completion:(void (^)(NSError* error, NSArray* entries)) callback;
-(void) getReadingList:(BCHDWUser*) user completion:(void (^)(NSError* error, NSArray* entries)) callback;
-(BOOL) isLoggedIn;
-(void) postEntry:(NSString*) entryText asUser:(BCHDWUser*) user completion:(void (^)(NSError* error, NSString* url)) callback;

@end
