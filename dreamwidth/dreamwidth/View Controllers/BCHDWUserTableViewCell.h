//
//  BCHDWUserTableViewCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCHDWUserTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* avatarView;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* usernameLabel;

@end
