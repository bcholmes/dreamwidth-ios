//
//  BCHDWSimpleTableViewCell.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWSimpleTableViewCell.h"

#import <UIColor-HexRGB/UIColor+HexRGB.h>

@implementation BCHDWSimpleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
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
