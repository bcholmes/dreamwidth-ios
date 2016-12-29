//
//  BCHDWTheme.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWTheme.h"

#import <UIColor-HexRGB/UIColor+HexRGB.h>

@interface BCHDWTheme ()

@property (nonatomic, strong) UIColor* dreamwidthRed;

@end

@implementation BCHDWTheme

-(id) init {
    if (self = [super init]) {
        self.dreamwidthRed = [UIColor colorWithHex:@"C1272D"];
        self.menuColor = self.dreamwidthRed;
    }
    return self;
}

-(void) configure {
    [self configureNavigationBars];
}

-(void) configureNavigationBars {
    UINavigationBar* barProxy = [UINavigationBar appearance];
    [barProxy setBarTintColor:self.dreamwidthRed];
    [barProxy setBarStyle:UIBarStyleBlack];
    [barProxy setTranslucent:NO];
    [barProxy setOpaque:NO];
    [barProxy setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                       }];
    [barProxy setTintColor:[UIColor whiteColor]];
    
}

@end
