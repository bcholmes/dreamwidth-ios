//
//  DreamwidthApi.h
//  dreamwidth
//
//  This is an implementation of the Dreamwidth Flat API, described in LiveJournal documentation:
//
//  https://www.livejournal.com/doc/server/ljp.csp.flat.protocol.html
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCHDWUser.h"

typedef NS_ENUM(NSInteger, DWErrorCodes) {
    DWAuthenticationFailedError = 1000,
    DWSessionError = 1001
};

#define DWErrorDomain @"org.ayizan.dreamballoon"


@interface DreamwidthApi : NSObject

@property (nonatomic, nullable, strong) BCHDWUser* currentUser;
@property (nonatomic, readonly) BOOL isSessionReady;

-(void) loginWithUser:(NSString* _Nonnull) userid password:(NSString* _Nonnull) password andCompletion:(void (^ _Nonnull)(NSError* _Nullable error, BCHDWUser* _Nullable user)) callback;
-(void) getEvents:(BCHDWUser* _Nonnull) user completion:(void (^ _Nonnull)(NSError* _Nullable error, NSArray* _Nullable entries)) callback;
-(void) getEvents:(BCHDWUser* _Nonnull) user since:(NSDate* _Nonnull) date completion:(void (^ _Nonnull)(NSError*  _Nonnull error, NSArray*  _Nonnull entries)) callback;
-(void) performFunctionWithWebSession:(void (^ _Nonnull)(NSError* _Nullable, NSString* _Nullable)) callback;
-(BOOL) isLoggedIn;
-(void) checkFriends:(NSDate* _Nonnull) date completion:(void (^ _Nonnull)(NSError* _Nullable error, BOOL newEntries)) callback;

@end
