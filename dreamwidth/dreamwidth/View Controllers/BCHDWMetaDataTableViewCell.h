//
//  BCHDWMetaDataTableViewCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-02.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWMetaDataTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* userLabel;
@property (nonatomic, strong) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UIImageView* avatarImageView;

@end

NS_ASSUME_NONNULL_END
