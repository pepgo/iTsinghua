//
//  FileViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FileViewController.h"
#import "FileListViewController.h"

@implementation FileViewController

#pragma mark - View lifecycle

- (void)getNewInfo {
    [self.mainTableView reloadData];
    int old = 0;
    int new = 0;
    int value;
    
    //get old count
    for (int i = 0; i < courseNameArray.count; i++) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"File-%@",[courseNameArray objectAtIndex:i]]]) {
            value = [(NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"File-%@",[courseNameArray objectAtIndex:i]]] intValue];
            old = old + value;
        } else {
            old = 0;
        }
    }
    
    //get new count
    //载入过快这里会崩溃，需要加一层判断
    if ([CourseInfo sharedCourseInfo].fileCount.count > 0) {
        for (int i = 0; i < courseNameArray.count; i++) {
            value = [(NSNumber *)[[CourseInfo sharedCourseInfo].fileCount objectAtIndex:i] intValue];
            new = new + value;
        } 
    } else {
        return;
    }
    
    if ((new - old) > 0) {
        [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:@"New"];
    }    
}

- (void)viewWillAppear:(BOOL)animated {
    [self getNewInfo];
}

- (void)viewDidLoad
{
    // Add the refresh button
    self.navigationItem.leftBarButtonItem = self.refreshButton;
    
    // Load the data source
    [self reloadDataSource];
    
    
    [super viewDidLoad];
}

- (void)reloadDataSource
{
    // No other content but the downloaded course names will be shown in this view.
    self.courseNameArray = [NSArray arrayWithArray:[CourseInfo sharedCourseInfo].courseName];
}

- (void)requestDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqual:thuRequestFinishNotification]) {
        [self reloadDataSource];
    }
    [super requestDidFinish:notification];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    cell.textLabel.text = [self.courseNameArray objectAtIndex:indexPath.row];
    if ([CourseInfo sharedCourseInfo].fileCount.count != 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"课件数目: %@", [[CourseInfo sharedCourseInfo].fileCount objectAtIndex:indexPath.row]];
    } else {
        cell.detailTextLabel.text = @"正在更新数据...";
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListViewController *controller = [[FileListViewController alloc] initWithCellStyle:UITableViewCellStyleSubtitle index:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
