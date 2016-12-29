//
//  BCHDWMenuViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWMenuViewController.h"

#import "AppDelegate.h"
#import "BCHDWMenuOption.h"


@interface BCHDWMenuViewController ()

@property (nonatomic, strong) NSArray* menuItems;

@end

@implementation BCHDWMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuItems = [BCHDWMenuOption enumValues];
    self.tableView.backgroundColor = [AppDelegate instance].theme.menuColor;
}


#pragma marl - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return section == 0 ? 0 : self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        static NSString* menuItemCellIdentifier = @"menuItem";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:menuItemCellIdentifier];
        BCHDWMenuOption* menuOption = self.menuItems[indexPath.row];
        cell.textLabel.text = menuOption.text;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [AppDelegate instance].theme.menuColor;
        return cell;
    } else {
        return nil;
    }
}

@end
