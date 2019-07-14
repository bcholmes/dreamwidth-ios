//
//  HTMLElement+DreamBalloon.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-13.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <HTMLKit/HTMLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTMLElement (DreamBalloon)

@property (nonatomic, readonly) BOOL isBlockElement;
@property (nonatomic, readonly) BOOL isHeader;

@end

NS_ASSUME_NONNULL_END
