//
//  BCHDWEntryLikedTableCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2021-07-31.
//  Copyright © 2021 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWEntryLikedTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* byLabel;
@property (nonatomic, weak) IBOutlet UILabel* dateLabel;

@end

NS_ASSUME_NONNULL_END
