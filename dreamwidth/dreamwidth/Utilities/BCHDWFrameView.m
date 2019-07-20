//
//  BCHDWFrameView.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-20.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWFrameView.h"

@implementation BCHDWFrameView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = 4.0;
    self.layer.masksToBounds = YES;
    
    self.layer.borderWidth = 1;
    self.layer.borderColor = [(self.borderColor == nil ? [UIColor grayColor] : self.borderColor) CGColor];
}

@end
