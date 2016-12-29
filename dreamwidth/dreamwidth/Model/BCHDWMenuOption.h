//
//  BCHDWMenuOption.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSEnum.h"

@interface BCHDWMenuOption : WSEnum

+ (BCHDWMenuOption*) ENTRIES;
+ (BCHDWMenuOption*) PROFILE;

@property (nonatomic, readonly) NSString* text;
@property (nonatomic, readonly) NSString* storyboardId;

@end
