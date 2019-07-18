//
//  BCHCommentTableViewCell.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-03.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWCommentTableViewCell.h"

@implementation BCHDWCommentTableViewCell

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
    
    BOOL first = YES;
    for (UIView* subview in self.stackView.arrangedSubviews) {
        if (!first) {
            [self.stackView removeArrangedSubview:subview];
            [subview removeConstraints:subview.constraints];
            [subview removeFromSuperview];
        }
        first = NO;
    };
}

-(IBAction) reply:(id)sender {
    [self.composer reply:self.comment];
}

@end
