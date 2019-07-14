//
//  BCHDWEntryCollectionViewCell.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-13.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntryCollectionViewCell.h"

@interface BCHDWEntryCollectionViewCell()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* widthContraint;

@end

@implementation BCHDWEntryCollectionViewCell

-(void) setWidth:(CGFloat) width {
    self.widthContraint.constant = width;
}

-(CGFloat) width {
    return self.widthContraint.constant;
}

@end
