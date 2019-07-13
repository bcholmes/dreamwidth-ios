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

#import "BCHDWAppDelegate.h"
#import "BCHDWCommentComposer.h"
#import "BCHDWCommentTableViewCell.h"
#import "BCHDWComposeReplyViewController.h"
#import "BCHDWEntryContentTableViewCell.h"
#import "BCHDWHTMLHelper.h"
#import "BCHDWMetaDataTableViewCell.h"
#import "BCHDWTheme.h"
#import "BCHDWUserStringHelper.h"
#import "NSString+DreamBalloon.h"

@interface BCHDWEntryDetailController ()<NSFetchedResultsControllerDelegate,BCHDWCommentComposer>

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSDateFormatter* formatter;
@property (nonatomic, strong) BCHDWComment* selectedComment;

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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self queryData:[BCHDWAppDelegate instance].managedObjectContext];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.selectedComment = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 2 : self.fetchedResultsController.fetchedObjects.count;
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
    } else if (indexPath.section == 0) {
        BCHDWEntryContentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"content" forIndexPath:indexPath];
        [self populateHtmlContent:self.entry.entryText stackView:cell.stackView];
        return cell;
    } else {
        BCHDWCommentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"comment" forIndexPath:indexPath];
        BCHDWComment* comment = self.fetchedResultsController.fetchedObjects[indexPath.row];
        
        if (comment.subject == nil || comment.subject.length == 0) {
            cell.subjectLabel.hidden = YES;
        } else {
            cell.subjectLabel.text = comment.subject;
            cell.subjectLabel.hidden = NO;
        }
        NSMutableAttributedString* labelText = [[[BCHDWUserStringHelper new] userLabel:comment.author font:cell.authorLabel.font] mutableCopy];
        [labelText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@", %@", [comment.creationDate timeAgoSinceNow]] attributes:@{ NSFontAttributeName : cell.authorLabel.font, NSForegroundColorAttributeName : [BCHDWTheme instance].primaryDarkColor}]];
        
        cell.authorLabel.textColor = nil;
        cell.authorLabel.attributedText = labelText;
        
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

-(void) populateHtmlContent:(NSString*) html stackView:(UIStackView*) stackView {
    if ([html isHTMLMarkupPresent] || [html isUserReferencePresent]) {
        NSArray* markedUpText = [[BCHDWHTMLHelper new] parseHtmlIntoAttributedStrings:html];
        for (NSAttributedString* string in markedUpText) {
            UILabel* commentTextLabel = [UILabel new];
            commentTextLabel.numberOfLines = 0;
            commentTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            commentTextLabel.attributedText = string;
            
            [stackView addArrangedSubview:commentTextLabel];
        }
    } else {
        UILabel* commentTextLabel = [UILabel new];
        commentTextLabel.numberOfLines = 0;
        commentTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        commentTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        commentTextLabel.text = html;
        
        [stackView addArrangedSubview:commentTextLabel];
    }
}

-(void) reply:(BCHDWComment*) comment {
    NSLog(@"comment is %@ (id=%@)", comment == nil ? @"nil" : @"not nil", comment.commentId);
    self.selectedComment = comment;
    [self performSegueWithIdentifier:@"comment" sender:nil];
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
