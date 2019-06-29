//
//  BCHDWEntryListViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-09.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "BCHDWEntryListViewController.h"

#import "BCHDWAppDelegate.h"
#import "BCHDWEntryTableViewCell.h"
#import "BCHDWEntry.h"
#import "UIViewController+Menu.h"

@interface BCHDWEntryListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSArray* entries;

@end

@implementation BCHDWEntryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeMenuButton];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    BCHDWDreamwidthService* service = [BCHDWAppDelegate instance].dreamwidthService;
    if ([service isLoggedIn]) {
        [self loadEntries];
    } else {
        [service addObserver:self forKeyPath:@"currentUser" options:NSKeyValueObservingOptionNew context:nil];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BCHDWDreamwidthService* service = [BCHDWAppDelegate instance].dreamwidthService;
    if (![service isLoggedIn]) {
        [self performSegueWithIdentifier:@"login" sender:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self loadEntries];
}

-(void) loadEntries {
    BCHDWDreamwidthService* service = [BCHDWAppDelegate instance].dreamwidthService;
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [service getEvents:^(NSError* error, NSArray* events) {
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

                    [service fetchRecentReadingPageActivity];
                }
            });
        }];
    });
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController* popup = segue.destinationViewController;
 
    popup.providesPresentationContextTransitionStyle = YES;
    popup.definesPresentationContext = YES;
    
    [popup setModalPresentationStyle:UIModalPresentationOverCurrentContext];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    if (self.entries == nil) {
        return 0;
    } else {
        return self.entries.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BCHDWEntryTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"entryCell"];
    BCHDWEntry* entry = self.entries[indexPath.row];
    cell.subjectLabel.text = entry.subject;
    cell.posterLabel.text = entry.poster;

    if (entry.pictureKeyword != nil) {
        BCHDWUser* user = [BCHDWAppDelegate instance].dreamwidthApi.currentUser;
        BCHDWAvatar* avatar = [user avatarByKeyword:entry.pictureKeyword];
        if (avatar != nil) {
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatar.url] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        }
    } else {
        cell.avatarImageView.image = nil;
    }
    
    return cell;
}

@end
