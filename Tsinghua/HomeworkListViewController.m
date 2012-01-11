//
//  HomeworkListViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HomeworkListViewController.h"
#import "HomeworkDetailViewController.h"
#import "CourseInfo.h"

@implementation HomeworkListViewController

@synthesize homeworkInfo;
@synthesize homeworkState;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the view title to the course name
    NSString *courseName = [[CourseInfo sharedCourseInfo].courseName objectAtIndex:selectedIndex];
    self.title = [NSString stringWithFormat:@"%@作业", courseName]; 
}

- (void)reloadDataSource
{
    self.homeworkInfo = [NSArray arrayWithArray:[CourseInfo sharedCourseInfo].homeworkInfo];
    self.homeworkState = [NSArray arrayWithArray:[CourseInfo sharedCourseInfo].homeworkState];
    [self.mainTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.homeworkInfo == nil) {
        // Generate the request url
        NSString *requestURL = [self requestStringByReplacing:@"course_locate" withString:@"hom_wk_brw" atIndex:selectedIndex];
        [self requestDidStartOfType:thuHomeworkRequest url:requestURL];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [homeworkInfo count];
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    cell.textLabel.text = [homeworkInfo objectAtIndex:indexPath.row];
    NSString *hState = [self.homeworkState objectAtIndex:indexPath.row];
    NSString *deadline = [[CourseInfo sharedCourseInfo].homeworkDeadline objectAtIndex:indexPath.row];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@    截止日期:%@", hState, deadline];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeworkDetailViewController *controller = [[HomeworkDetailViewController alloc] initWithIndex:indexPath.row courseName:[[CourseInfo sharedCourseInfo].courseName objectAtIndex:selectedIndex]];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
