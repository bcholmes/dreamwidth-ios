//
//  BCHDWLoginViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-08.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "BCHDWLoginViewController.h"
#import "DreamwidthApi.h"

@interface BCHDWLoginViewController ()

@property (nonatomic, weak) IBOutlet UITextField* usernameField;
@property (nonatomic, weak) IBOutlet UITextField* passwordField;

@end

@implementation BCHDWLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(IBAction) login:(id)sender {
    NSString* username = self.usernameField.text;
    NSString* password = self.passwordField.text;
    
    DreamwidthApi* api = [[DreamwidthApi alloc] init];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [api loginWithUser:username password:password andCompletion:^(NSError* error, BCHDWUser* user) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (error != nil) {
                    [[[UIAlertView alloc] initWithTitle:@"Error occurred"
                                                message:@"There was a problem communicating with Dreamwidth"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                } else {
                    NSLog(@"Logged in as user %@", user.name);
                    
                    [self getEntries:user];
                }
            });
        }];
    });
}

-(void) getEntries:(BCHDWUser*) user {
    DreamwidthApi* api = [[DreamwidthApi alloc] init];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [api getEvents:user completion:^(NSError* error, NSArray* events) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (error != nil) {
                    [[[UIAlertView alloc] initWithTitle:@"Error occurred"
                                                message:@"There was a problem communicating with Dreamwidth"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                } else {
                    NSLog(@"entries found");
                
                }
            });
        }];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
