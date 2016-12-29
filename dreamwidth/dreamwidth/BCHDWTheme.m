//
//  BCHDWTheme.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWTheme.h"

#import <UIColor-HexRGB/UIColor+HexRGB.h>

#import "BCHDWSimpleTableViewCell.h"
#import "BCHDWProfileMainTableViewCell.h"

@interface BCHDWTheme ()

@property (nonatomic, strong) UIColor* dreamwidthRed;
@property (nonatomic, strong) UIColor* dreamwidthPink;

@end

@implementation BCHDWTheme

-(id) init {
    if (self = [super init]) {
        self.dreamwidthRed = [UIColor colorWithHex:@"C1272D"];
        self.dreamwidthPink = [UIColor colorWithHex:@"FFEEED"];
        self.menuColor = self.dreamwidthRed;
        self.primaryColor = self.dreamwidthRed;
        self.loginScreenColor = self.dreamwidthPink;
    }
    return self;
}

-(void) configure {
    [self configureNavigationBars];
    [self configureButtons];
    [self configureSimpleCell];
    [self configureProfileMainCell];
}

-(void) configureButtons {
    UIButton* proxy = [UIButton appearance];
    [proxy setTitleColor:self.dreamwidthRed forState:UIControlStateNormal];
    [proxy setTitleColor:[UIColor colorWithHex:@"666666"] forState:UIControlStateHighlighted];
}

-(void) configureSimpleCell {
    BCHDWSimpleTableViewCell* proxy = [BCHDWSimpleTableViewCell appearance];
    proxy.selectedBackgroundColor = [UIColor colorWithHex:@"9F000A"];
}

-(void) configureProfileMainCell {
    BCHDWProfileMainTableViewCell* proxy = [BCHDWProfileMainTableViewCell appearance];
    proxy.backgroundColor = self.dreamwidthRed;
    proxy.textLabelColor = [UIColor whiteColor];
    proxy.selectedBackgroundColor = [UIColor colorWithHex:@"9F000A"];
}


-(void) configureNavigationBars {
    UINavigationBar* barProxy = [UINavigationBar appearance];
    [barProxy setBarTintColor:self.dreamwidthRed];
    [barProxy setBarStyle:UIBarStyleBlack];
    [barProxy setTranslucent:NO];
    [barProxy setOpaque:NO];
    [barProxy setTitleTextAttributes:@{
                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                       }];
    [barProxy setTintColor:[UIColor whiteColor]];
    
}

@end
