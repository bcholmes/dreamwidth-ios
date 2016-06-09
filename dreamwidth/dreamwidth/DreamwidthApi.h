//
//  DreamwidthApi.h
//  dreamwidth
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCHDWUser.h"

@interface DreamwidthApi : NSObject

-(void) loginWithUser:(NSString*) userid password:(NSString*) password andCompletion:(void (^)(NSError* error, BCHDWUser* user)) callback;
-(void) getEvents:(BCHDWUser*) user completion:(void (^)(NSError* error, NSArray* entries)) callback;
-(void) getReadingList:(BCHDWUser*) user completion:(void (^)(NSError* error, NSArray* entries)) callback;

@end
