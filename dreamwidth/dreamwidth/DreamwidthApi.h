//
//  DreamwidthApi.h
//  dreamwidth
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DreamwidthApi : NSObject

-(void) loginWithUser:(NSString*) userid password:(NSString*) password andCompletion:(void (^)(NSError*)) callback;


@end
