//
//  BCHDWImageBlockTableViewCell.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-18.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWImageBlockTableViewCell.h"

@implementation BCHDWImageBlockTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openLink)];
    singleTap.numberOfTapsRequired = 1;
    [self.imageBlockView setUserInteractionEnabled:YES];
    [self.imageBlockView addGestureRecognizer:singleTap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) openLink {
    if (self.link != nil) {
        @try {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.link] options:@{} completionHandler:nil];
        } @catch (NSException* exception) {
            NSLog(@"******************************************");
            NSLog(@"%@", exception.reason);
            NSLog(@"******************************************");
        }
    }
}

@end
