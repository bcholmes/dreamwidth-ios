//
//  BCHDWLoginViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-08.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

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
    NSLog(@"Login");
    
    NSString* username = self.usernameField.text;
    NSString* password = self.passwordField.text;
    
    DreamwidthApi* api = [[DreamwidthApi alloc] init];
    [api loginWithUser:username password:password andCompletion:^(NSError* error) {
        if (error != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error occurred"
                                                            message:@"There was a problem communicating with Dreamwidth"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        } else {
            NSLog(@"Did the thing!");
        }
    }];
    
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
