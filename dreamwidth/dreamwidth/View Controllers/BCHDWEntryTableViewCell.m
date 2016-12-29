//
//  BCHDWEntryTableViewCell.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-09.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BCHDWEntryTableViewCell.h"

@implementation BCHDWEntryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.cardView.layer.cornerRadius = 2;
    
    self.cardView.layer.masksToBounds = NO;
    self.cardView.layer.shadowOffset = CGSizeMake(0, 3);
    self.cardView.layer.shadowRadius = 5;
    self.cardView.layer.shadowOpacity = 0.5;
    self.cardView.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
