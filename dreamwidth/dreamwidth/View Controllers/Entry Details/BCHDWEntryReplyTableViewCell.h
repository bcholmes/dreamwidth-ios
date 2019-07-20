//
//  BCHDWEntryReplyTableViewCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-20.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BCHDWCommentComposer.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWEntryReplyTableViewCell : UITableViewCell

@property (nonatomic, strong) NSObject<BCHDWCommentComposer>* composer;

@end

NS_ASSUME_NONNULL_END
