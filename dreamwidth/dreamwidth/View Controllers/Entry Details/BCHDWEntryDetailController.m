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
#import <DateTools/NSDate+DateTools.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <MaterialComponents/MaterialSnackbar.h>

#import "BCHDWAppDelegate.h"
#import "BCHDWCommentComposer.h"
#import "BCHDWCommentTableViewCell.h"
#import "BCHDWComposeReplyViewController.h"
#import "BCHDWEntryLikedTableCell.h"
#import "BCHDWEntryReplyTableViewCell.h"
#import "BCHDWHTMLHelper.h"
#import "BCHDWImageBlockTableViewCell.h"
#import "BCHDWMetaDataTableViewCell.h"
#import "BCHDWTextBlockTableViewCell.h"
#import "BCHDWTheme.h"
#import "BCHDWUserStringHelper.h"
#import "NSString+DreamBalloon.h"

@interface BCHDWEntryDetailController ()<NSFetchedResultsControllerDelegate,BCHDWCommentComposer>

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSDateFormatter* formatter;
@property (nonatomic, strong) BCHDWComment* selectedComment;
@property (nonatomic, strong) NSArray<BCHDWBlock*>* blocks;

@end

@implementation BCHDWEntryDetailController

-(instancetype) initWithCoder:(NSCoder*) coder {
    if (self = [super initWithCoder:coder]) {
        self.formatter = [NSDateFormatter new];
        self.formatter.dateFormat = @"yyyy-MMM-dd hh:mm a";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshStuff) forControlEvents:UIControlEventValueChanged];
    
    self.blocks = [[BCHDWHTMLHelper new] parseHtmlIntoAttributedStrings:self.entry.entryText];
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self queryData:[BCHDWAppDelegate instance].managedObjectContext];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.selectedComment = nil;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void) refreshStuff {
    [[BCHDWAppDelegate instance].dreamwidthService refreshEntry:self.entry.handle  callback:^(NSError * _Nullable error) {
        [self.entry.managedObjectContext refreshObject:self.entry mergeChanges:NO];
        dispatch_async(dispatch_get_main_queue(), ^{

            [self.refreshControl endRefreshing];
            if (error == nil) {
                [self.tableView reloadData];
            }
        });
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.blocks.count + 2 : self.fetchedResultsController.fetchedObjects.count;
}


- (UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        BCHDWMetaDataTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"metaData" forIndexPath:indexPath];

        cell.titleLabel.text = self.entry.subject;
        cell.userLabel.textColor = nil;
        cell.userLabel.attributedText = [[BCHDWUserStringHelper new] userLabel:self.entry.author font:cell.userLabel.font];
        cell.dateLabel.text = [self.formatter stringFromDate:self.entry.creationDate];
        cell.lockedImageView.hidden = !self.entry.locked;
        
        if (self.entry.avatarUrl != nil) {
            [cell.avatarImageView setImageWithURL:[NSURL URLWithString:self.entry.avatarUrl] placeholderImage:[UIImage imageNamed:@"user"]];
        } else {
            cell.avatarImageView.image = nil;
        }

        return cell;
    } else if (indexPath.section == 0 && indexPath.row == self.blocks.count + 1) {
        BCHDWEntryReplyTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"replyCell" forIndexPath:indexPath];
        cell.composer = self;
        cell.isLiked = [self isLiked];
        return cell;
    } else if (indexPath.section == 0) {
        BCHDWBlock* block = self.blocks[indexPath.row-1];
        
        if ([block isKindOfClass:[BCHDWTextBlock class]]) {
            BCHDWTextBlockTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"textBlockCell" forIndexPath:indexPath];
            cell.bodyLabel.textColor = nil;
            cell.bodyLabel.attributedText = ((BCHDWTextBlock*) block).text;
            
            for (BCHDWAnchor* anchor in ((BCHDWTextBlock*) block).links) {
                [cell.bodyLabel setLink:anchor.href forRange:NSMakeRange(anchor.location, anchor.length)];
            }
            
            return cell;
        } else {
            BCHDWImageBlockTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"imageBlockCell" forIndexPath:indexPath];

            __weak UIImageView* weakImage = cell.imageBlockView;
            [cell.imageBlockView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:((BCHDWImageBlock*) block).imageUrl]] placeholderImage:[UIImage imageNamed:@"image-icon"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage* image) {
                
                CGFloat width = cell.bounds.size.width;
                cell.heightConstraint.constant = image.size.height / image.size.width * width;
                [self.tableView beginUpdates];
                weakImage.image = image;
                [self.tableView endUpdates];
                
            } failure:nil];
            cell.link = ((BCHDWImageBlock*) block).link;
            return cell;
        }
    } else {
        BCHDWComment* comment = self.fetchedResultsController.fetchedObjects[indexPath.row];
        if (comment.isLike) {
            BCHDWEntryLikedTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"likedCell" forIndexPath:indexPath];
            cell.byLabel.text = [NSString stringWithFormat:@"by %@", comment.author];
            cell.dateLabel.text = [comment.creationDate timeAgoSinceNow];
            return cell;
        } else {
            BCHDWCommentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"comment" forIndexPath:indexPath];
            
            if (comment.subject == nil || comment.subject.length == 0) {
                cell.subjectLabel.hidden = YES;
            } else {
                cell.subjectLabel.text = comment.subject;
                cell.subjectLabel.hidden = NO;
            }
            NSMutableAttributedString* labelText = [[[BCHDWUserStringHelper new] userLabel:comment.author font:cell.authorLabel.font] mutableCopy];
            if (comment.replyTo != nil) {
                [labelText appendAttributedString:[[NSAttributedString alloc] initWithString:@" > " attributes:@{ NSFontAttributeName : cell.authorLabel.font }]];
                [labelText appendAttributedString:[[BCHDWUserStringHelper new] userLabel:comment.replyTo.author font:cell.authorLabel.font]];
            }
            
            cell.authorLabel.textColor = nil;
            cell.authorLabel.attributedText = labelText;
            cell.dateLabel.text = [comment.creationDate timeAgoSinceNow];
            
            if (comment.avatarUrl != nil) {
                [cell.avatarImageView setImageWithURL:[NSURL URLWithString:comment.avatarUrl] placeholderImage:[UIImage imageNamed:@"user"]];
            } else {
                cell.avatarImageView.image = nil;
            }
            
            cell.composer = self;
            cell.comment = comment;
            cell.leftConstraint.constant = 16 + (comment.depthAsInteger - 1) * 8;
            [self populateHtmlContent:comment.commentText stackView:cell.stackView];
            
            return cell;
        }
    }
}

-(void) populateHtmlContent:(NSString*) html stackView:(UIStackView*) stackView {
    if ([html isHTMLMarkupPresent] || [html isUserReferencePresent]) {
        NSArray* markedUpText = [[BCHDWHTMLHelper new] parseHtmlIntoAttributedStrings:html];
        for (BCHDWBlock* block in markedUpText) {
            if ([block isKindOfClass:[BCHDWTextBlock class]]) {
                UILabel* commentTextLabel = [UILabel new];
                commentTextLabel.numberOfLines = 0;
                commentTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
                commentTextLabel.attributedText = ((BCHDWTextBlock*) block).text;
                
                [stackView addArrangedSubview:commentTextLabel];
            } else if ([block isKindOfClass:[BCHDWImageBlock class]]) {
                UIImageView* imageView = [UIImageView new];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                __weak UIImageView* weakImage = imageView;
                [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:((BCHDWImageBlock*) block).imageUrl]] placeholderImage:[UIImage imageNamed:@"image-icon"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage* image) {

                    [self.tableView beginUpdates];
                    weakImage.image = image;
                    [self.tableView endUpdates];
                    
                } failure:nil];
                [stackView addArrangedSubview:imageView];
            }
        }
    } else {
        UILabel* commentTextLabel = [UILabel new];
        commentTextLabel.numberOfLines = 0;
        commentTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        commentTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        commentTextLabel.text = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [stackView addArrangedSubview:commentTextLabel];
    }
}

-(void) reply:(BCHDWComment*) comment {
    NSLog(@"comment is %@ (id=%@)", comment == nil ? @"nil" : @"not nil", comment.commentId);
    self.selectedComment = comment;
    [self performSegueWithIdentifier:@"comment" sender:nil];
}

-(void) like {
    [SVProgressHUD show];
    [[BCHDWAppDelegate instance].dreamwidthService postLike:self.entry callback:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];

        if (error != nil) {
            [[MDCSnackbarManager new] showMessage:[MDCSnackbarMessage messageWithText:@"Ooops. We ran into a problem trying to post your like."]];
        }
        [self refreshStuff];
    }];
}

-(BOOL) isLiked {
    NSString* author = [BCHDWAppDelegate instance].dreamwidthService.currentUser.username;
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ [NSPredicate predicateWithFormat:@"liked == YES"], [NSPredicate predicateWithFormat:@"author == %@", author], [NSPredicate predicateWithFormat:@"entry == %@", self.entry] ]];
    NSError* error = nil;
    NSArray* results = [[BCHDWAppDelegate instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error == nil) {
        return results.count > 0;
    } else {
        return false;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BCHDWComposeReplyViewController* controller = segue.destinationViewController;
    controller.entry = self.entry;
    controller.comment = self.selectedComment;
}

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
