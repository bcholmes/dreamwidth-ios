//
//  BCHDWDreamwidthService.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DreamwidthApi.h"
#import "BCHDWCommentEntryData.h"
#import "BCHDWPersistenceService.h"
#import "BCHDWUser.h"

#define NEW_ENTRY_NOTIFICATION_ID @"new-entry-"


typedef void (^backgroundFetchHandler)(UIBackgroundFetchResult result);

@interface BCHDWDreamwidthService : NSObject

@property (nonatomic, nullable, strong) BCHDWUser* currentUser;

-(instancetype _Nonnull ) initWithApi:(DreamwidthApi*_Nonnull) api persistence:(BCHDWPersistenceService*_Nonnull) persistenceService;
-(BOOL) isLoggedIn;

-(void) loginWithUser:(NSString*) userid password:(NSString*) password andCompletion:(void (^)(NSError* error, BCHDWUser* user)) callback;
-(void) postEntry:(NSString*) entryText completion:(void (^)(NSError* error, NSString* url)) callback;
-(void) fetchRecentReadingPageActivity;
-(void) syncWithServer;
-(void) postComment:(BCHDWCommentEntryData*) comment entry:(BCHDWEntry*) entry parentComment:(BCHDWComment*) parentComment callback:(void (^) (NSError*)) callback;
-(void) scheduleBackgroundDownload:(backgroundFetchHandler) completionHandler;
-(void) refreshEntry:(BCHDWEntryHandle* _Nonnull) entryHandle callback:(void (^ _Nullable) (NSError* _Nullable))  callback;
-(void) fetchEntry:(BCHDWEntryHandle* _Nonnull) entryHandle callback:(void (^ _Nullable) (NSError* _Nullable))  callback;
-(void) generateApiKey:(void (^ _Nullable) (NSString* _Nullable, NSError* _Nullable))  callback;

@end
