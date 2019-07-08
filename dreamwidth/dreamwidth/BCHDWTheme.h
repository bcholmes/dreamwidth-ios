//
//  BCHDWTheme.h
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MaterialComponents/MaterialTextFields.h>

@interface BCHDWTheme : NSObject

-(void) configure;

@property (nonatomic, strong) UIColor* primaryDarkColor;
@property (nonatomic, strong) UIColor* primaryColor;
@property (nonatomic, strong) UIColor* menuColor;
@property (nonatomic, strong) UIColor* loginScreenColor;
@property (nonatomic, strong) UIColor* primaryTextColor;

-(void) applyTheme:(MDCTextInputControllerBase*) textInputController;

+(instancetype) instance;

@end
