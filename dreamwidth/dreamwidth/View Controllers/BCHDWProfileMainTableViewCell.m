//
//  BCHDWProfileMainTableViewCell.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWProfileMainTableViewCell.h"

@implementation BCHDWProfileMainTableViewCell

-(void) layoutSubviews {
    [super layoutSubviews];
    self.usernameLabel.textColor = self.textLabelColor;
    self.nameLabel.textColor = self.textLabelColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    UIView * selectedBackgroundView = [[UIView alloc] init];
    if (self.selectedBackgroundColor != nil) {
        [selectedBackgroundView setBackgroundColor:self.selectedBackgroundColor];
    }
    [self setSelectedBackgroundView:selectedBackgroundView];
}
@end
