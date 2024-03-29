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
#import "BCHDWCardView.h"
#import "BCHDWFrameView.h"
#import "BCHDWMainCollectionView.h"
#import "BCHDWMainTableView.h"
#import "BCHDWProfileMainTableViewCell.h"
#import "BCHDWSimpleTableViewCell.h"

@interface BCHDWTheme ()

@property (nonatomic, strong) UIColor* dreamwidthRed;
@property (nonatomic, strong) UIColor* dreamwidthPink;
@property (nonatomic, strong) UIColor* dreamBalloonBlue;
@property (nonatomic, strong) UIColor* dreamBalloonLightBlue;
@property (nonatomic, strong) UIColor* dreamBalloonMutedBlue;

@property (nonatomic, strong) UIColor* dreamBalloonLightRed;

@end

@implementation BCHDWTheme

-(id) init {
    if (self = [super init]) {
        self.dreamwidthRed = [UIColor colorWithHex:@"c5353c"];
        self.dreamwidthPink = [UIColor colorWithHex:@"ffdcd9"];
        self.dreamBalloonBlue = [UIColor colorWithHex:@"5a8394"];
        self.dreamBalloonLightBlue = [UIColor colorWithHex:@"abc1c9"];
        self.dreamBalloonMutedBlue = [UIColor colorWithHex:@"edfaff"];
        self.dreamBalloonLightRed = [UIColor colorWithHex:@"e0c3c0"];
        self.menuColor = self.dreamwidthRed;
        self.primaryColor = self.dreamwidthRed;
        self.primaryDarkColor = [UIColor colorWithHex:@"463730"];
        self.loginScreenColor = self.dreamwidthPink;
        self.primaryTextColor = [UIColor colorWithHex:@"333333"];
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
    [self configureMainCollectionView];
    [self configureMainTableView];
    [self configureNavigationBars];
    [self configureButtons];
    [self configureFrameView];
    [self configureCardView];
    [self configureMaterialButton];
    [self configureBackgroundView];
    [self configureBannerView];
    [self configureSimpleCell];
    [self configureProfileMainCell];
    [self configureFlatButton];
    [self configureLabel];
}

-(void) configureMainCollectionView {
    BCHDWMainCollectionView* proxy = [BCHDWMainCollectionView appearance];
    proxy.backgroundColor = self.dreamwidthPink;
}

-(void) configureMainTableView {
    BCHDWMainTableView* proxy = [BCHDWMainTableView appearance];
    proxy.backgroundColor = self.dreamwidthPink;
}

-(void) configureFrameView {
    BCHDWFrameView* proxy = [BCHDWFrameView appearance];
    proxy.borderColor = [UIColor colorWithHex:@"d8d8d8"];
}

-(void) configureLabel {
    UILabel* proxy = [UILabel appearance];
    proxy.textColor = [UIColor colorWithHex:@"333333"];
}

-(void) configureButtons {
    UIButton* proxy = [UIButton appearance];
    [proxy setTitleColor:self.dreamwidthRed forState:UIControlStateNormal];
    [proxy setTitleColor:[UIColor colorWithHex:@"666666"] forState:UIControlStateHighlighted];
}

-(void) configureCardView {
    BCHDWCardView* proxy = [BCHDWCardView appearance];
    proxy.inkColor = [self.primaryColor colorWithAlphaComponent:0.32];
}

-(void) configureSimpleCell {
    BCHDWSimpleTableViewCell* proxy = [BCHDWSimpleTableViewCell appearance];
    proxy.selectedBackgroundColor = [UIColor clearColor];
}

-(void) configureBannerView {
    BCHDWBannerView* proxy = [BCHDWBannerView appearance];
    proxy.backgroundColor = self.dreamBalloonLightRed;
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
    [proxy setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [proxy setTitleColor:self.dreamwidthRed forState:UIControlStateNormal];
    [proxy setTitleColor:[UIColor colorWithHex:@"888888"] forState:UIControlStateDisabled];
}

-(void) applyTheme:(MDCTextInputControllerBase*) textInputController {
    textInputController.errorColor = self.dreamwidthRed;
    textInputController.activeColor = self.dreamBalloonBlue;
    textInputController.floatingPlaceholderActiveColor = self.dreamBalloonLightBlue;
}
@end
