//
//  BCHDWMenuViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWMenuViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SWRevealViewController/SWRevealViewController.h>

#import "BCHDWAppDelegate.h"
#import "BCHDWMenuOption.h"
#import "BCHDWTheme.h"
#import "BCHDWUserTableViewCell.h"

@interface BCHDWMenuViewController ()

@property (nonatomic, strong) NSArray* menuItems;

@end

@implementation BCHDWMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuItems = [BCHDWMenuOption enumValues];
    self.tableView.backgroundColor = [BCHDWTheme instance].menuColor;
}


#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return section == 0 ? 1 : self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        static NSString* menuItemCellIdentifier = @"menuItem";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:menuItemCellIdentifier];
        BCHDWMenuOption* menuOption = self.menuItems[indexPath.row];
        cell.textLabel.text = menuOption.text;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [BCHDWTheme instance].menuColor;
        return cell;
    } else {
        static NSString* userCellIdentifier = @"userCell";
        BCHDWUserTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:userCellIdentifier];
        BCHDWUser* user = [BCHDWAppDelegate instance].dreamwidthApi.currentUser;
        
        cell.nameLabel.text = user.name;
        cell.nameLabel.textColor = [UIColor whiteColor];
        cell.usernameLabel.text = user.username;
        cell.usernameLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [BCHDWTheme instance].menuColor;
        BCHDWAvatar* avatar = user.defaultAvatar;
        if (avatar != nil) {
            [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:avatar.url] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        }
        
        return cell;
    }
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        BCHDWMenuOption* menu = (BCHDWMenuOption*) self.menuItems[indexPath.row];
        SWRevealViewController* revealController = self.revealViewController;
        
        UIViewController* newFrontController = [self.storyboard instantiateViewControllerWithIdentifier:menu.storyboardId];
        [revealController pushFrontViewController:newFrontController animated:YES];
    }
}

-(CGFloat) tableView:(UITableView*) tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath {
    return indexPath.section == 0 ? 100.0 : 40.0;
}

@end
