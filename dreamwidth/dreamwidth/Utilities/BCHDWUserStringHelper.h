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

-(NSAttributedString*) userLabel:(NSString* _Nonnull) username;
-(NSAttributedString*) userLabel:(NSString* _Nonnull) username font:(UIFont*) font;
-(NSAttributedString*) userLabel:(NSString* _Nullable) username icon:(UIImage* _Nullable) icon font:(UIFont* _Nonnull) font;

@end

NS_ASSUME_NONNULL_END
