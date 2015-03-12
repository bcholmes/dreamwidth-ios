//
//  ViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import "ViewController.h"
#import "DreamwidthApi.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(doTheThing)];
    self.navigationItem.rightBarButtonItem = button;

}

-(void) doTheThing {
    NSLog(@"We did the thing");
    DreamwidthApi* api = [[DreamwidthApi alloc] init];
    [api loginWithUser:@"fred" password:@"wilma" andCompletion:^(NSError* error) {
        if (error != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error occurred"
                                                            message:@"There was a problem communicating with Dreamwidth"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
        } else {
            NSLog(@"Did the thing!");
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
