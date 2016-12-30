//
//  BCHDWProfileTableViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWProfileTableViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>


#import "AppDelegate.h"
#import "BCHDWAvatarTableViewCell.h"
#import "BCHDWAvatarTableViewController.h"
#import "BCHDWProfileMainTableViewCell.h"
#import "UIViewController+Menu.h"

#define MAX_RECORDS 10


@interface BCHDWProfileTableViewController ()

@property (nonatomic, strong) BCHDWUser* user;

@end

@implementation BCHDWProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeMenuButton];
    
    self.tableView.backgroundColor = [AppDelegate instance].theme.primaryColor;
    self.user = [AppDelegate instance].dreamwidthApi.currentUser;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return 2;
}

- (NSString*) tableView:(UITableView*) tableView titleForHeaderInSection:(NSInteger) section {
    if(section == 0) {
        return nil;
    } else if(section == 1) {
        return @"Icons";
    } else {
        return @"Title2";
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return MIN(MAX_RECORDS + 1, self.user.avatars.count);
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        BCHDWProfileMainTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"mainCell" forIndexPath:indexPath];
        cell.nameLabel.text = self.user.name;
        cell.usernameLabel.text = self.user.username;
        BCHDWAvatar* avatar = self.user.defaultAvatar;
        if (avatar != nil) {
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatar.url]];
        }
        
        return cell;
    } else if (indexPath.section == 1 && indexPath.row < MAX_RECORDS) {
        BCHDWAvatarTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"avatarCell" forIndexPath:indexPath];
        BCHDWAvatar* avatar = self.user.avatars[indexPath.row];
        [cell populateFromAvatar:avatar];
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"moreCell" forIndexPath:indexPath];
        return cell;
    } else {
        return nil;
    }
}


-(CGFloat) tableView:(UITableView*) tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        return 190.0;
    } else if (indexPath.section == 1) {
        return 66.0;
    } else {
        return 40.0;
    }
}


- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 1 && indexPath.row == MAX_RECORDS) {
        [self performSegueWithIdentifier:@"avatarList" sender:nil];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"avatarList"]) {
        BCHDWAvatarTableViewController* controller = [segue destinationViewController];
        controller.user = self.user;
    }

}

@end
