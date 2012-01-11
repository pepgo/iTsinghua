//
//  NotesViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NotesViewController.h"
#import "NoteListViewController.h"

@implementation NotesViewController

#pragma mark - View lifecycle

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
    [self.mainTableView reloadData];
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
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Do not forget to clear up all the previous note data
    [[[CourseInfo sharedCourseInfo] noteBasicInfo] removeAllObjects];
    
    // Push to the note list view for the selected course
    NoteListViewController *noteListViewController = [[NoteListViewController alloc] initWithCellStyle:UITableViewCellStyleSubtitle 
                                                                                                 index:indexPath.row];
    [self.navigationController pushViewController:noteListViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
