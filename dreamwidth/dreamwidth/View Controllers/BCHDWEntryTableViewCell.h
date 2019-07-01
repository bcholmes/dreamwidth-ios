//
//  BCHDWEntryTableViewCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-09.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCHDWEntryTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView* cardView;
@property (nonatomic, weak) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel* posterLabel;
@property (nonatomic, weak) IBOutlet UILabel* subjectLabel;
@property (nonatomic, weak) IBOutlet UILabel* commentCountLabel;

@end
