//
//  BCHDWAvatarPickerViewController.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-24.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BCHDWAvatar.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^selectionHandler)(BCHDWAvatar*);

@interface BCHDWAvatarPickerViewController : UICollectionViewController

@property (nonatomic, copy) selectionHandler onSelection;

@end

NS_ASSUME_NONNULL_END
