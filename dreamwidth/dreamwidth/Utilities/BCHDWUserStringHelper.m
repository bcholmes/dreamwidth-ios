//
//  BCHDWUserStringHelper.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-07.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWUserStringHelper.h"

#import "BCHDWTheme.h"

@implementation BCHDWUserStringHelper

-(NSAttributedString*) userLabel:(NSString*) username {
    return [self userLabel:username font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
}

-(NSAttributedString*) userLabel:(NSString*) username font:(UIFont*) font {
    return [self userLabel:username icon:nil font:font];
}

-(NSAttributedString*) userLabel:(NSString*) username icon:(UIImage*) icon font:(UIFont*) font {
    if (icon == nil) {
        icon = [UIImage imageNamed:@"user-small"];
    }
    NSMutableAttributedString* result = [NSMutableAttributedString new];
    
    NSTextAttachment* textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = icon;
    
    [result appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    [result appendAttributedString:[[NSAttributedString alloc] initWithString:username attributes:@{ NSFontAttributeName : font, NSForegroundColorAttributeName : [BCHDWTheme instance].primaryDarkColor}]];
    
    return result;
}
@end
