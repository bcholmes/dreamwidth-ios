//
//  BCHDWEntryContentTableViewCell.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-06.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BCHDWCommentComposer.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWEntryContentTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIStackView* stackView;

@property (nonatomic, strong) NSObject<BCHDWCommentComposer>* composer;

@end

NS_ASSUME_NONNULL_END
