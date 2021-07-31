//
//  BCHDWEntryReplyTableViewCell.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-20.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntryReplyTableViewCell.h"

@implementation BCHDWEntryReplyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction) reply:(id)sender {
    [self.composer reply:nil];
}

-(IBAction) like:(id)sender {
    [self.composer like];
}


@end
