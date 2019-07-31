//
//  HTMLUtilities.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-31.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <HTMLKit/HTMLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWHTMLUtilities : NSObject

+(BOOL) isExcluded:(HTMLElement*) element;
+(BOOL) isUserReference:(HTMLElement*) element;

@end

NS_ASSUME_NONNULL_END
