//
//  BCHDWUserStringHelper.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-07.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWUserStringHelper : NSObject

-(NSAttributedString*) userLabel:(NSString*) username;
-(NSAttributedString*) userLabel:(NSString*) username font:(UIFont*) font;

@end

NS_ASSUME_NONNULL_END
