//
//  BCHDWEntryCollectionViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-13.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWEntryCollectionViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <CoreData/CoreData.h>
#import <MaterialComponents/MaterialAppBar.h>
#import <DateTools/NSDate+DateTools.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "BCHDWAppDelegate.h"
#import "BCHDWEntryCollectionViewCell.h"
#import "BCHDWEntryDetailController.h"
#import "BCHDWEntry.h"
#import "BCHDWLoginViewController.h"
#import "BCHDWTheme.h"
#import "BCHDWUserStringHelper.h"

@interface BCHDWEntryCollectionViewController ()<NSFetchedResultsControllerDelegate, MDCFlexibleHeaderViewLayoutDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MDCAppBar* appBar;
@property (nonatomic, strong) UIImageView* headerImage;
@property (nonatomic, assign) CGFloat maxHeaderHeight;
@property (nonatomic, strong) BCHDWEntry* selectedEntry;
@property (nonatomic, strong) BCHDWUserStringHelper* userHelper;
@property (nonatomic, strong) NSTimer* timer;

@end

@implementation BCHDWEntryCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureAppBar];

    self.userHelper = [BCHDWUserStringHelper new];
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    CGFloat width = self.collectionView.bounds.size.width;
    layout.estimatedItemSize = CGSizeMake(width, 400);

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self queryData:[BCHDWAppDelegate instance].managedObjectContext];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BCHDWDreamwidthService* service = [BCHDWAppDelegate instance].dreamwidthService;
    if (![service isLoggedIn]) {
        [self performSegueWithIdentifier:@"login" sender:nil];
    }
}

-(void) configureAppBar {
    self.appBar = [MDCAppBar new];
    
    self.appBar.headerViewController.view.backgroundColor = [BCHDWTheme instance].primaryColor;
    self.appBar.navigationBar.backgroundColor = [UIColor clearColor];
    self.appBar.headerViewController.layoutDelegate = self;
    [self.appBar.navigationBar setTitle:nil];
    
    [self addChildViewController:self.appBar.headerViewController];
    self.headerImage = [UIImageView new];
    self.headerImage.image = [UIImage imageNamed:@"announcements_header"];
    self.headerImage.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImage.clipsToBounds = YES;
    self.headerImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGFloat imageAspectRatio = 72.0f/120.0f;
    CGFloat screenWidth = self.view.bounds.size.width;
    NSLog(@"screen width %f", screenWidth);
    self.appBar.headerViewController.headerView.minimumHeight = 44 + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.appBar.headerViewController.headerView.maximumHeight = self.maxHeaderHeight = MIN(240, screenWidth * imageAspectRatio);
    self.headerImage.frame = self.appBar.headerViewController.headerView.bounds;
    
    [self.appBar.headerViewController.headerView insertSubview:self.headerImage atIndex:0];
    
    self.appBar.headerViewController.headerView.trackingScrollView = self.collectionView;
    
    [self.appBar addSubviewsToParent];
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


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BCHDWEntryCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"entry" forIndexPath:indexPath];
    BCHDWEntry* entry = self.fetchedResultsController.fetchedObjects[indexPath.row];
    cell.titleLabel.text = entry.subject;
    cell.authorLabel.attributedText = [self.userHelper userLabel:entry.author font:cell.authorLabel.font];
    if (entry.summaryText != nil && entry.summaryText.length > 0) {
        cell.summaryLabel.hidden = NO;
        cell.summaryLabel.text = entry.summaryText;
    } else {
        cell.summaryLabel.hidden = YES;
    }
    if (entry.summaryText2 != nil && entry.summaryText2.length > 0) {
        cell.summary2Label.hidden = NO;
        cell.summary2Label.text = entry.summaryText2;
    } else {
        cell.summary2Label.hidden = YES;
    }
    if (entry.summaryImageUrl != nil && entry.summaryImageUrl.length > 0) {
        cell.summaryImageView.hidden = NO;
        [cell.summaryImageView setImageWithURL:[NSURL URLWithString:entry.summaryImageUrl] placeholderImage:[UIImage imageNamed:@"image-icon"]];
    } else {
        cell.summaryImageView.hidden = YES;
    }

    cell.dateLabel.text = [entry.creationDate timeAgoSinceNow];
    cell.lockedImageView.hidden = !entry.locked;

    if (entry.avatarUrl != nil) {
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:entry.avatarUrl] placeholderImage:[UIImage imageNamed:@"user"]];
    } else {
        cell.avatarImageView.image = [UIImage imageNamed:@"user"];
    }
    
    if ([entry.numberOfComments integerValue] == 0) {
        cell.commentLabel.text = @"";
    } else if ([entry.numberOfComments integerValue] == 1) {
        cell.commentLabel.text = @"1 comment";
    } else {
        cell.commentLabel.text = [NSString stringWithFormat:@"%@ comments", entry.numberOfComments];
    }

    CGFloat width = self.collectionView.bounds.size.width;
    cell.width = width - 32;
    
    return cell;
}

- (void) collectionView:(UICollectionView*) collectionView didSelectItemAtIndexPath:(NSIndexPath*) indexPath {
    self.selectedEntry = self.fetchedResultsController.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"detail" sender:nil];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

-(void) scrollViewDidScroll:(UIScrollView*) scrollView {
    [self.appBar.headerViewController.headerView trackingScrollViewDidScroll];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView*) scrollView {
    [self.appBar.headerViewController.headerView trackingScrollViewDidEndDecelerating];
}

-(void) scrollViewDidEndDragging:(UIScrollView*) scrollView willDecelerate:(BOOL) decelerate {
    [self.appBar.headerViewController.headerView trackingScrollViewDidEndDraggingWillDecelerate:decelerate];
}

-(void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self.appBar.headerViewController.headerView trackingScrollViewWillEndDraggingWithVelocity:velocity targetContentOffset:targetContentOffset];
}



#pragma mark MDCFlexibleHeaderViewLayoutDelegate

- (void)flexibleHeaderViewController:(nonnull MDCFlexibleHeaderViewController *)flexibleHeaderViewController flexibleHeaderViewFrameDidChange:(nonnull MDCFlexibleHeaderView *)flexibleHeaderView {
    
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
    if (self.timer != nil) {
        [self.timer invalidate];
    } else {
        [SVProgressHUD show];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(refresh) userInfo:nil repeats:NO];
    
}

-(void) refresh {
    [self.collectionView reloadData];
    [SVProgressHUD dismiss];
}
@end
