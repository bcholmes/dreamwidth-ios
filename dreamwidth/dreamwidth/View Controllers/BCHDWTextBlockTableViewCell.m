//
//  BCHDWTextBlockTableViewCell.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-18.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWTextBlockTableViewCell.h"

@implementation BCHDWTextBlockTableViewCell

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
    [self.bodyLabel clearActionDictionary];
}

@end
