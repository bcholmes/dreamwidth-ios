//
//  BCHDWDreamwidthService.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DreamwidthApi.h"
#import "BCHDWPersistenceService.h"
#import "BCHDWUser.h"

@interface BCHDWDreamwidthService : NSObject

@property (nonatomic, strong) BCHDWUser* currentUser;

-(instancetype) initWithApi:(DreamwidthApi*) api persistence:(BCHDWPersistenceService*) persistenceService;
-(BOOL) isLoggedIn;

-(void) loginWithUser:(NSString*) userid password:(NSString*) password andCompletion:(void (^)(NSError* error, BCHDWUser* user)) callback;
-(void) postEntry:(NSString*) entryText completion:(void (^)(NSError* error, NSString* url)) callback;
-(void) fetchRecentReadingPageActivity;
-(void) syncWithServer;

@end
