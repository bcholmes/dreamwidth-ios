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
#import "BCHDWProfileMainTableViewCell.h"
#import "UIViewController+Menu.h"

@interface BCHDWProfileTableViewController ()

@end

@implementation BCHDWProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeMenuButton];
    
    self.tableView.backgroundColor = [AppDelegate instance].theme.primaryColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        BCHDWUser* user = [AppDelegate instance].dreamwidthApi.currentUser;
        
        BCHDWProfileMainTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"mainCell" forIndexPath:indexPath];
        cell.nameLabel.text = user.name;
        cell.usernameLabel.text = user.username;
        BCHDWAvatar* avatar = user.defaultAvatar;
        if (avatar != nil) {
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatar.url]];
        }
        
        return cell;
    } else {
        return nil;
    }
}


-(CGFloat) tableView:(UITableView*) tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath {
    return indexPath.section == 0 ? 200.0 : 40.0;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
