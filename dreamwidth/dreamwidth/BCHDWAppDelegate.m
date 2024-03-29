//
//  AppDelegate.m
//  dreamwidth
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import <SWRevealViewController/SWRevealViewController.h>
#import <UserNotifications/UserNotifications.h>

#import "BCHDWAppDelegate.h"
#import "BCHDWTheme.h"
#import "BCHDWPersistenceService.h"

@interface BCHDWAppDelegate ()<UNUserNotificationCenterDelegate>

@property (nonatomic, strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic, strong) BCHDWPersistenceService* persistentService;
@property (nonatomic, strong) NSTimer* timer;

@end

@implementation BCHDWAppDelegate

+(BCHDWAppDelegate*) instance {
    return (BCHDWAppDelegate*) [[UIApplication sharedApplication] delegate];
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
    self.persistentService = [[BCHDWPersistenceService alloc] initWithManagedObjectContext:self.managedObjectContext];
    self.dreamwidthService = [[BCHDWDreamwidthService alloc] initWithApi:self.dreamwidthApi persistence:self.persistentService];
    [BCHDWTheme instance];
//    [self setUpRevealController];
    
    [UIApplication.sharedApplication setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self.timer invalidate];
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
    
    [self registerForNotifications];
    [self.dreamwidthService syncWithServer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 * 60.0 target:self.dreamwidthService selector:@selector(syncWithServer) userInfo:nil repeats:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    NSLog(@"performFetchWithCompletionHandler");
    [self.dreamwidthService scheduleBackgroundDownload:completionHandler];
}

-(void) registerForNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            center.delegate = self;
            NSLog(@"request succeeded!");
            /*
             dispatch_async(dispatch_get_main_queue(), ^{
             [self addWelcomeNotifications];
             });
             */
        } else {
            NSLog(@"No user notifications for you!");
        }
    }];
}

- (void)application:(UIApplication*) app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if ([error.domain isEqualToString:NSCocoaErrorDomain] && error.code == 3010) {
        NSLog(@"%@", error.localizedDescription);
    } else {
        NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

#pragma mark CoreData

- (NSManagedObjectModel*) managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}


- (NSManagedObjectContext*) managedObjectContext {
    if (_managedObjectContext == nil) {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            _managedObjectContext.persistentStoreCoordinator = coordinator;
        }
    }
    return _managedObjectContext;
}

/**
 Returns the URL to the application's documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}

- (NSPersistentStoreCoordinator*) persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    } else {
        NSString *documentsStorePath = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:@"Dreamwidth.sqlite"];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        // Add the default store to our coordinator.
        NSError *error;
        NSURL *defaultStoreURL = [NSURL fileURLWithPath:documentsStorePath];
        NSDictionary* options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:defaultStoreURL
                                                             options:options
                                                               error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
        
        return _persistentStoreCoordinator;
    }
}

-(void) processNotification:(NSString*) notificationIdentifier {
    NSLog(@"Notification id %@", notificationIdentifier);
}

#pragma mark UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter*) center didReceiveNotificationResponse:(UNNotificationResponse*) response withCompletionHandler:(void (^)(void)) completionHandler {
    
    [self processNotification:response.notification.request.identifier];
    
    if (completionHandler != nil) {
        completionHandler();
    }
}

- (void) userNotificationCenter:(UNUserNotificationCenter*) center willPresentNotification:(UNNotification*) notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options)) completionHandler {
    if (completionHandler) {
        completionHandler(UNNotificationPresentationOptionNone);
    }
}

@end
