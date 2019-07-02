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
#import "BCHDWEntryDetailController.h"
#import "BCHDWLoginViewController.h"
#import "BCHDWTheme.h"
#import "UIViewController+Menu.h"

@interface BCHDWEntryListViewController ()<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) BCHDWEntry* selectedEntry;

@end

@implementation BCHDWEntryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeMenuButton];

    self.view.backgroundColor = [BCHDWTheme instance].loginScreenColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self queryData:[BCHDWAppDelegate instance].managedObjectContext];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BCHDWDreamwidthService* service = [BCHDWAppDelegate instance].dreamwidthService;
    if (![service isLoggedIn]) {
        [self performSegueWithIdentifier:@"login" sender:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController* popup = segue.destinationViewController;
    
    if ([popup isKindOfClass:[BCHDWLoginViewController class]]) {
 
        popup.providesPresentationContextTransitionStyle = YES;
        popup.definesPresentationContext = YES;
        
        [popup setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    } else if ([popup isKindOfClass:[BCHDWEntryDetailController class]]) {
        ((BCHDWEntryDetailController*) popup).entry = self.selectedEntry;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BCHDWEntryTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"entryCell"];
    BCHDWEntry* entry = self.fetchedResultsController.fetchedObjects[indexPath.row];
    cell.subjectLabel.text = entry.subject;
    cell.posterLabel.text = entry.author;

    if (entry.avatarUrl != nil) {
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:entry.avatarUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    } else {
        cell.avatarImageView.image = nil;
    }
    
    if ([entry.numberOfComments integerValue] == 0) {
        cell.commentCountLabel.text = @"";
    } else if ([entry.numberOfComments integerValue] == 1) {
        cell.commentCountLabel.text = @"1 comment";
    } else {
        cell.commentCountLabel.text = [NSString stringWithFormat:@"%@ comments", entry.numberOfComments];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedEntry = self.fetchedResultsController.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"detail" sender:nil];
}

#pragma mark - Core Data

- (void) queryData:(NSManagedObjectContext*) managedObjectContext {
    
    // Set up the fetched results controller if needed.
    if (self.fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:managedObjectContext];
        fetchRequest.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO] ];
        
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
