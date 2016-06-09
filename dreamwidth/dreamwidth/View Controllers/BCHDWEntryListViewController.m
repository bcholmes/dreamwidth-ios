//
//  BCHDWEntryListViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-09.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>

#import "BCHDWEntryListViewController.h"

#import "AppDelegate.h"
#import "BCHDWEntryTableViewCell.h"
#import "BCHDWEntry.h"

@interface BCHDWEntryListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSArray* entries;

@end

@implementation BCHDWEntryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self loadEntries];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadEntries {
    DreamwidthApi* api = [AppDelegate instance].dreamwidthApi;
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [api getEvents:nil completion:^(NSError* error, NSArray* events) {
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
                    self.entries = events;
                    [self.tableView reloadData];
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    if (self.entries == nil) {
        return 3;
    } else {
        return self.entries.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BCHDWEntryTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"entryCell"];
    BCHDWEntry* entry = self.entries[indexPath.row];
    cell.subjectLabel.text = entry.subject;
    return cell;
}

@end
