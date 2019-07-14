//
//  BCHDWEntryContentTableViewCell.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-06.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntryContentTableViewCell.h"

@implementation BCHDWEntryContentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) prepareForReuse {
    [super prepareForReuse];
    
    for (UIView* subview in self.stackView.arrangedSubviews) {
        [self.stackView removeArrangedSubview:subview];
        [subview removeConstraints:subview.constraints];
        [subview removeFromSuperview];
    };
}

-(IBAction) reply:(id)sender {
    [self.composer reply:nil];
}

@end
