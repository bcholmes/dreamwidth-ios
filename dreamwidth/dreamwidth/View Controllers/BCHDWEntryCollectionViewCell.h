//
//  BCHDWEntryCollectionViewCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-13.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWEntryCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel* authorLabel;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* summaryLabel;
@property (nonatomic, weak) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel* commentLabel;

@property (nonatomic, assign) CGFloat width;

@end

NS_ASSUME_NONNULL_END
