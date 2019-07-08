//
//  BCHCommentTableViewCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-03.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BCHDWComment.h"
#import "BCHDWCommentComposer.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWCommentTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* authorLabel;
@property (nonatomic, strong) IBOutlet UILabel* subjectLabel;
@property (nonatomic, strong) IBOutlet UIStackView* stackView;
@property (nonatomic, strong) IBOutlet UIImageView* avatarImageView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint* leftConstraint;

@property (nonatomic, nonnull, strong) BCHDWComment* comment;

@property (nonatomic, strong) NSObject<BCHDWCommentComposer>* composer;

@end

NS_ASSUME_NONNULL_END
