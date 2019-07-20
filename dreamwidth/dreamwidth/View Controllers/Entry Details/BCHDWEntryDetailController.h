//
//  BCHDWEntryDetailController.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-02.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BCHDWEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWEntryDetailController : UITableViewController

@property (nonatomic, nonnull, strong) BCHDWEntry* entry;

@end

NS_ASSUME_NONNULL_END
