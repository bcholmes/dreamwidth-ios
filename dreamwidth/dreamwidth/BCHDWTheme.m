//
//  BCHDWTheme.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWTheme.h"

#import <MaterialComponents/MaterialButtons.h>
#import <MaterialComponents/MaterialTextFields.h>
#import <UIColor-HexRGB/UIColor+HexRGB.h>

#import "BCHDWBannerView.h"
#import "BCHDWBackgroundView.h"
#import "BCHDWProfileMainTableViewCell.h"
#import "BCHDWSimpleTableViewCell.h"

@interface BCHDWTheme ()

@property (nonatomic, strong) UIColor* dreamwidthRed;
@property (nonatomic, strong) UIColor* dreamwidthPink;
@property (nonatomic, strong) UIColor* dreamBalloonBlue;
@property (nonatomic, strong) UIColor* dreamBalloonLightBlue;

@end

@implementation BCHDWTheme

-(id) init {
    if (self = [super init]) {
        self.dreamwidthRed = [UIColor colorWithHex:@"c5353c"];
        self.dreamwidthPink = [UIColor colorWithHex:@"ffdcd9"];
        self.dreamBalloonBlue = [UIColor colorWithHex:@"5a8394"];
        self.dreamBalloonLightBlue = [UIColor colorWithHex:@"abc1c9"];
        self.menuColor = self.dreamwidthRed;
        self.primaryColor = self.dreamwidthRed;
        self.loginScreenColor = self.dreamwidthPink;
    }
    return self;
}

+(instancetype) instance {
    static BCHDWTheme* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BCHDWTheme alloc] init];
        [sharedInstance configure];
    });
    return sharedInstance;
}

-(void) configure {
    [self configureNavigationBars];
    [self configureButtons];
    [self configureMaterialButton];
    [self configureBackgroundView];
    [self configureBannerView];
    [self configureSimpleCell];
    [self configureProfileMainCell];
    [self configureFlatButton];
}

-(void) configureButtons {
    UIButton* proxy = [UIButton appearance];
    [proxy setTitleColor:self.dreamwidthRed forState:UIControlStateNormal];
    [proxy setTitleColor:[UIColor colorWithHex:@"666666"] forState:UIControlStateHighlighted];
}

-(void) configureSimpleCell {
    BCHDWSimpleTableViewCell* proxy = [BCHDWSimpleTableViewCell appearance];
    proxy.selectedBackgroundColor = [UIColor clearColor];
}

-(void) configureBannerView {
    BCHDWBannerView* proxy = [BCHDWBannerView appearance];
    proxy.backgroundColor = self.dreamwidthPink;
}

-(void) configureBackgroundView {
    BCHDWBackgroundView* proxy = [BCHDWBackgroundView appearance];
    proxy.backgroundColor = self.dreamwidthPink;
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
    [barProxy setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor] }];
    [barProxy setTintColor:[UIColor whiteColor]];

    // remove bottom separator line from navigation bar
    [barProxy setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [barProxy setShadowImage:[[UIImage alloc] init]];
}

-(void) configureFlatButton {
    MDCFlatButton* proxy = [MDCFlatButton appearance];
    proxy.tintColor = [UIColor whiteColor];
    proxy.inkColor = [[UIColor whiteColor] colorWithAlphaComponent:0.32];
    proxy.disabledAlpha = 1.0;
    proxy.uppercaseTitle = NO;
    [proxy setBackgroundColor:self.dreamwidthRed forState:UIControlStateNormal];
    [proxy setBackgroundColor:[UIColor colorWithHex:@"888888"] forState:UIControlStateDisabled];
    [proxy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void) configureMaterialButton {
    MDCButton* proxy = [MDCButton appearance];
    proxy.tintColor = self.dreamwidthRed;
    proxy.inkColor = [self.dreamwidthRed colorWithAlphaComponent:0.32];
    proxy.disabledAlpha = 1.0;
    proxy.uppercaseTitle = NO;
    [proxy setTitleColor:self.dreamwidthRed forState:UIControlStateNormal];
    [proxy setTitleColor:[UIColor colorWithHex:@"888888"] forState:UIControlStateDisabled];
}

-(void) applyTheme:(MDCTextInputControllerBase*) textInputController {
    textInputController.errorColor = self.dreamwidthRed;
    textInputController.activeColor = self.dreamBalloonBlue;
    textInputController.floatingPlaceholderActiveColor = self.dreamBalloonLightBlue;
}
@end
