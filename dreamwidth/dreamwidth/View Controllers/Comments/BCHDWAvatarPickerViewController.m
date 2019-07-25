//
//  BCHDWAvatarPickerViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-24.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWAvatarPickerViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <tgmath.h>

#import "BCHDWAppDelegate.h"
#import "BCHDWAvatarPickerCollectionViewCell.h"

@interface BCHDWAvatarPickerViewController ()

@property (nonatomic, strong) NSArray* avatarList;

@end

@implementation BCHDWAvatarPickerViewController

static NSString * const reuseIdentifier = @"avatarCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.avatarList = [BCHDWAppDelegate instance].dreamwidthService.currentUser.avatars;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.avatarList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BCHDWAvatarPickerCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    BCHDWAvatar* avatar = [self.avatarList objectAtIndex:indexPath.row];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:avatar.url] placeholderImage:[UIImage imageNamed:@"user"]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BCHDWAvatar* avatar = [self.avatarList objectAtIndex:indexPath.row];
    if (self.onSelection != nil) {
        self.onSelection(avatar);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

- (CGSize)collectionView:(UICollectionView*) collectionView layout:(UICollectionViewLayout*) collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*) indexPath {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        CGFloat width = self.collectionView.bounds.size.width / 4.0;
        return CGSizeMake(width, width);
    } else {
        CGFloat count = self.collectionView.bounds.size.width / 80.0;
        CGFloat width = self.collectionView.bounds.size.width / floor(count);
        return CGSizeMake(width, width);
    }
}
@end
