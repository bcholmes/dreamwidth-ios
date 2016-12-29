//
//  BCHDWProfileMainTableViewCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCHDWProfileMainTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* usernameLabel;

@property (nonatomic, strong) UIColor* selectedBackgroundColor;
@property (nonatomic, strong) UIColor* textLabelColor;

@end
