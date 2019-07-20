//
//  NSAttributedString+DreamBalloon.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-19.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (DreamBalloon)

-(NSAttributedString*) attributedStringByTrimmingCharacters:(NSCharacterSet*) set;

@end

@interface NSMutableAttributedString (DreamBalloon)

-(void) trimCharacters:(NSCharacterSet*) set;

@end
NS_ASSUME_NONNULL_END
