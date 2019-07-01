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
#import "BCHDWEntryOld.h"
#import "UIViewController+Menu.h"

@interface BCHDWEntryListViewController ()<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

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
    [self queryData:[BCHDWAppDelegate instance].managedObjectContext];
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
    
    return cell;
}

- (void) queryData:(NSManagedObjectContext*) managedObjectContext {
    
    // Set up the fetched results controller if needed.
    if (self.fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:managedObjectContext];
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
        fetchRequest.sortDescriptors = @[ sortDescriptor1 ];//, sortDescriptor2 ];
        
        
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
