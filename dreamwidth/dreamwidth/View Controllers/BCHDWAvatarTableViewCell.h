//
//  BCHDWAvatarTableViewCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCHDWAvatar.h"


@interface BCHDWAvatarTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel* avatarKeywordsLabel;

-(void) populateFromAvatar:(BCHDWAvatar*) avatar;

@end
