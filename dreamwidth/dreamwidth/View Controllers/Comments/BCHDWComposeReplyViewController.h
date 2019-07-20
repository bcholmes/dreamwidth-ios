//
//  BCHDWComposeReplyViewController.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-08.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BCHDWEntry.h"
#import "BCHDWComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWComposeReplyViewController : UIViewController

@property (nonatomic, nonnull, strong) BCHDWEntry* entry;
@property (nonatomic, nonnull, strong) BCHDWComment* comment;

@end

NS_ASSUME_NONNULL_END
