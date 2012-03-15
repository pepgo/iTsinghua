//
//  NoteListViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NoteListViewController.h"
#import "CourseInfo.h"
#import "THUNetworkManager.h"
#import "NoteDetailViewController.h"


static NSString *noteBaseURL = @"http://learn.tsinghua.edu.cn/MultiLanguage/public/bbs/";

@implementation NoteListViewController

@synthesize basicNoteInfo;
@synthesize noteTimeArray;
@synthesize noteURLArray;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the view title to the course name
    self.title = [[CourseInfo sharedCourseInfo].courseName objectAtIndex:selectedIndex];
}

- (void)requestDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqualToString:thuRequestFinishNotification]) {
        [self reloadDataSource];
    }
    [super requestDidFinish:notification];
}

- (void)reloadDataSource
{
    self.basicNoteInfo = [NSArray arrayWithArray:[CourseInfo sharedCourseInfo].noteBasicInfo];
    self.noteTimeArray = [NSArray arrayWithArray:[CourseInfo sharedCourseInfo].noteUpDate];
    self.noteURLArray = [NSArray arrayWithArray:[CourseInfo sharedCourseInfo].noteURL];
    [self.mainTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *requestURL;
    if (self.basicNoteInfo == nil) {
        if ([[THUNetworkManager sharedManager] isTeacher]) {
            requestURL = [self requestStringByReplacing:@"/lesson/teacher/course_locate.jsp?" 
                                             withString:@"/public/bbs/getnoteid_teacher.jsp?module_id=122&" atIndex:selectedIndex];
        } else {
            requestURL = [self requestStringByReplacing:@"/lesson/student/course_locate.jsp" 
                                             withString:@"/public/bbs/getnoteid_student.jsp" atIndex:selectedIndex];
        }
        
        NSLog(@"%@",requestURL);
        
        [self requestDidStartOfType:thuNoteRequest url:requestURL];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [basicNoteInfo count];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    cell.textLabel.text = [self.basicNoteInfo objectAtIndex:indexPath.row];
    NSString *noteTime = [NSString stringWithFormat:@"发布日期:%@", [self.noteTimeArray objectAtIndex:indexPath.row]];
    cell.detailTextLabel.text = noteTime;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = [noteBaseURL stringByAppendingString:[self.noteURLArray objectAtIndex:indexPath.row]];
    NoteDetailViewController *controller = [[NoteDetailViewController alloc] initWithURLString:urlString];
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
