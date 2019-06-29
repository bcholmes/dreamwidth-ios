//
//  AppDelegate.h
//  dreamwidth
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DreamwidthApi.h"
#import "BCHDWDreamwidthService.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) DreamwidthApi* dreamwidthApi;
@property (nonatomic, strong) BCHDWDreamwidthService* dreamwidthService;

+(AppDelegate*) instance;

@end

