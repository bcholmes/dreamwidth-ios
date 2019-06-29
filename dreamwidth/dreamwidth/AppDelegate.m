//
//  AppDelegate.m
//  dreamwidth
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import <SWRevealViewController/SWRevealViewController.h>

#import "AppDelegate.h"
#import "BCHDWTheme.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+(AppDelegate*) instance {
    return (AppDelegate*) [[UIApplication sharedApplication] delegate];
}


-(void) setUpRevealController {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = window;
    

    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* menuViewController = [storyboard instantiateViewControllerWithIdentifier:@"menu"];

    UINavigationController* rootNavigationController = [storyboard instantiateInitialViewController];
    
    SWRevealViewController* revealController = [[SWRevealViewController alloc]
                                                initWithRearViewController:menuViewController frontViewController:rootNavigationController];
//    revealController.delegate = self;
    
    [self.window setRootViewController:revealController];
    [self.window makeKeyAndVisible];
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.dreamwidthApi = [DreamwidthApi new];
    self.dreamwidthService = [[BCHDWDreamwidthService alloc] initWithApi:self.dreamwidthApi];
    [BCHDWTheme instance];
    [self setUpRevealController];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
