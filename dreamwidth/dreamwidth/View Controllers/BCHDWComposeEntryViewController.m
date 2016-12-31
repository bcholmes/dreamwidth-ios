//
//  BCHDWComposeEntryViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-31.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWComposeEntryViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>

#import "AppDelegate.h"

@interface BCHDWComposeEntryViewController ()

@property (nonatomic, weak) IBOutlet UITextView* entryText;

@end

@implementation BCHDWComposeEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postEntry:)];
    self.navigationItem.rightBarButtonItem = button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) postEntry:(id)sender {
    NSString* text = self.entryText.text;
    if (text.length > 0) {
    
        BCHDWDreamwidthService* service = [AppDelegate instance].dreamwidthService;
        [SVProgressHUD show];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [service postEntry:text completion:^(NSError *error, NSString *url) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (error != nil) {
                        [[[UIAlertView alloc] initWithTitle:@"Error occurred"
                                                    message:@"There was a problem communicating with Dreamwidth"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil] show];
                    } else {
                        NSLog(@"post thing happened");
                        
                        
                    }
                });
            }];
        });
    }
}



@end
