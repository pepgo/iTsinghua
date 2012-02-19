//
//  HomeworkViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HomeworkViewController.h"
#import "HomeworkListViewController.h"
#import "THUNotifications.h"

@implementation HomeworkViewController

@synthesize countOfUnhandledHomeworks;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    // Set the left nav button to refresh button
    self.navigationItem.leftBarButtonItem = self.refreshButton;
    [super viewDidLoad];
}

- (void)reloadDataSource
{
    // Set up the data source
    self.courseNameArray = [NSArray arrayWithArray:[CourseInfo sharedCourseInfo].courseName];
    self.countOfUnhandledHomeworks = [[NSArray alloc] initWithArray:[CourseInfo sharedCourseInfo].countOfUnhandledHomeworks];
    [self.mainTableView reloadData];
    
    // Enumerate the unhandled homework array, calculate the count and warn the user.
    int sum = 0;
    for (NSString *intString in countOfUnhandledHomeworks) {
        int value = intString.intValue;
        sum += value;
    }
    if (sum > 0) {
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d", sum]];
    }
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
    // Send the request to get all the course info
    if ([CourseInfo sharedCourseInfo].courseName.count == 0) {
        [self requestDidStartOfType:thuCourseRequest url:nil];
    }
    [self reloadDataSource];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)requestDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqual:thuRequestFinishNotification]) {
        [self reloadDataSource];
    }
    [super requestDidFinish:notification];
}


#pragma mark - Table view data source

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell label font
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    
    // Set the label text
    cell.textLabel.text = [self.courseNameArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"未交作业数目: %@", [self.countOfUnhandledHomeworks objectAtIndex:indexPath.row]];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeworkListViewController *controller = [[HomeworkListViewController alloc] initWithCellStyle:UITableViewCellStyleSubtitle index:indexPath.row];
    //self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
