//
//  BCHDWTextBlockTableViewCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-18.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BCHDWHyperlinkLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWTextBlockTableViewCell : UITableViewCell

@property (nonatomic, nullable, weak) IBOutlet BCHDWHyperlinkLabel* bodyLabel;

@end

NS_ASSUME_NONNULL_END
