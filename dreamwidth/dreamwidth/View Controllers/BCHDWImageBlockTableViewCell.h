//
//  BCHDWImageBlockTableViewCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-18.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWImageBlockTableViewCell : UITableViewCell

@property (nonatomic, nullable, weak) IBOutlet UIImageView* imageBlockView;
@property (nonatomic, nullable, weak) IBOutlet NSLayoutConstraint* heightConstraint;

@end

NS_ASSUME_NONNULL_END
