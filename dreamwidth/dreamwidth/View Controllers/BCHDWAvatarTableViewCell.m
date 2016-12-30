//
//  BCHDWAvatarTableViewCell.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWAvatarTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>


@implementation BCHDWAvatarTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) populateFromAvatar:(BCHDWAvatar*) avatar {
    self.avatarKeywordsLabel.text = avatar.keywords;
    if (avatar != nil) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatar.url]];
    }
}

@end
