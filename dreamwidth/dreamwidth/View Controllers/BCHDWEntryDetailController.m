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

#import "BCHDWAppDelegate.h"
#import "BCHDWCommentTableViewCell.h"
#import "BCHDWMetaDataTableViewCell.h"

@interface BCHDWEntryDetailController ()<NSFetchedResultsControllerDelegate>

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
    [self queryData:[BCHDWAppDelegate instance].managedObjectContext];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : self.fetchedResultsController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDateFormatter* formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MMM-dd hh:mm a";
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        BCHDWMetaDataTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"metaData" forIndexPath:indexPath];

        cell.titleLabel.text = self.entry.subject;
        cell.userLabel.text = self.entry.author;
        cell.dateLabel.text = [formatter stringFromDate:self.entry.creationDate];
        
        if (self.entry.avatarUrl != nil) {
            [cell.avatarImageView setImageWithURL:[NSURL URLWithString:self.entry.avatarUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        } else {
            cell.avatarImageView.image = nil;
        }

        return cell;
    } else {
        BCHDWCommentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"comment" forIndexPath:indexPath];
        BCHDWComment* comment = self.fetchedResultsController.fetchedObjects[indexPath.row];
        
        NSLog(@"Subject: %@", comment.subject);
        if (comment.subject == nil || comment.subject.length == 0) {
            cell.subjectLabel.hidden = YES;
        } else {
            cell.subjectLabel.text = comment.subject;
            cell.subjectLabel.hidden = NO;
        }
        cell.authorLabel.text = [NSString stringWithFormat:@"%@ on %@", comment.author, [formatter stringFromDate:comment.creationDate]];
        cell.commentTextLabel.text = comment.commentText;
        
        if (comment.avatarUrl != nil) {
            [cell.avatarImageView setImageWithURL:[NSURL URLWithString:comment.avatarUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        } else {
            cell.avatarImageView.image = nil;
        }
        
        cell.leftConstraint.constant = 16 + (comment.depthAsInteger - 1) * 8;
        
        return cell;
    }
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

#pragma mark - Core Data

- (void) queryData:(NSManagedObjectContext*) managedObjectContext {
    
    // Set up the fetched results controller if needed.
    if (self.fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:managedObjectContext];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"entry == %@", self.entry];
        fetchRequest.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:@"orderKey" ascending:YES] ];
        
        NSFetchedResultsController* aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        NSError* error;
        if (![self.fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        }
    }
}

- (void) controllerDidChangeContent:(NSFetchedResultsController*) controller {
    [self.tableView reloadData];
}

@end
