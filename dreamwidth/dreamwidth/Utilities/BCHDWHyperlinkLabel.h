//
//  BCHDWHyperlinkLabel.h
//  dreamwidth
//
//  A non-trivial amount of this code was shamelessly stolen
//  from null09264's FRHyperLabel project
//
//  Created by BC Holmes on 2019-07-24.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWHyperlinkLabel : UILabel

- (void)setLink:(NSString*) link forRange:(NSRange) range;
- (void)clearActionDictionary;

@end

NS_ASSUME_NONNULL_END
