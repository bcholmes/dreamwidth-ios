//
//  BCHDWDreamwidthService.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DreamwidthApi.h"
#import "BCHDWUser.h"

@interface BCHDWDreamwidthService : NSObject

-(instancetype) initWithApi:(DreamwidthApi*) api;
-(BOOL) isLoggedIn;

-(void) loginWithUser:(NSString*) userid password:(NSString*) password andCompletion:(void (^)(NSError* error, BCHDWUser* user)) callback;

-(void) postEntry:(NSString*) entryText completion:(void (^)(NSError* error, NSString* url)) callback;

@end
