//
//  BCHDWEntryCollectionViewCell.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-13.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntryCollectionViewCell.h"
#import "BCHDWCardView.h"

@interface BCHDWEntryCollectionViewCell()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* widthContraint;
@property (nonatomic, weak) IBOutlet BCHDWCardView* cardView;

@end

@implementation BCHDWEntryCollectionViewCell

-(void) setHighlighted:(BOOL)highlighted {
    self.cardView.highlighted = highlighted;
}

-(void) setWidth:(CGFloat) width {
    self.widthContraint.constant = width;
}

-(CGFloat) width {
    return self.widthContraint.constant;
}

@end
