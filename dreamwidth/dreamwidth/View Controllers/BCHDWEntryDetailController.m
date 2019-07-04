//
//  BCHDWEntryDetailController.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-02.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntryDetailController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <CoreData/CoreData.h>

#import "BCHDWMetaDataTableViewCell.h"

@interface BCHDWEntryDetailController ()

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

@end

@implementation BCHDWEntryDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BCHDWMetaDataTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"metaData" forIndexPath:indexPath];

    NSDateFormatter* formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm a";
    
    cell.titleLabel.text = self.entry.subject;
    cell.userLabel.text = self.entry.author;
    cell.dateLabel.text = [formatter stringFromDate:self.entry.creationDate];
    
    if (self.entry.avatarUrl != nil) {
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:self.entry.avatarUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    } else {
        cell.avatarImageView.image = nil;
    }

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
