//
//  FileListViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FileListViewController.h"
#import "CourseInfo.h"
#import "FileContentViewController.h"
#import "THUFileManager.h"

@implementation FileListViewController

@synthesize courseName;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    if (fileListArray == nil) 
    {
        NSString *requestURL;
        if ([[THUNetworkManager sharedManager] isTeacher]) {
            requestURL = [self requestStringByReplacing:@"/lesson/teacher/course_locate.jsp?" 
                                                       withString:@"/lesson/teacher/download.jsp?module_id=121&" atIndex:self.selectedIndex];
        } else {
            requestURL = [self requestStringByReplacing:@"/lesson/student/course_locate.jsp" 
                                             withString:@"/lesson/student/download.jsp" atIndex:self.selectedIndex];
        }
                
        // Clear up the former stored file data
        [[CourseInfo sharedCourseInfo].fileListInfo removeAllObjects];
        
        // Start the request
        [self requestDidStartOfType:thuFileListRequest url:requestURL];
    }
    [super viewDidAppear:animated];
}

- (void)reloadDataSource
{
    fileListArray = [[CourseInfo sharedCourseInfo] fileListInfo];
    fileSizeArray = [[CourseInfo sharedCourseInfo] fileSizeInfo];
    fileLinkURLArray = [[CourseInfo sharedCourseInfo] fileLinkURLInfo];
    
    [self.mainTableView reloadData];
}

- (void)requestDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqual:thuRequestFinishNotification]) {
        [self reloadDataSource];
    }
    [super requestDidFinish:notification];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // load the course name and set the title
    self.courseName = [[CourseInfo sharedCourseInfo].courseName objectAtIndex:self.selectedIndex];
    [[THUFileManager defaultManager] switchToCurrentFolder:self.courseName];
    self.title = self.courseName;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [fileSizeArray count];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = [fileListArray objectAtIndex:indexPath.row];
    NSString *fileType = [[THUFileManager defaultManager] extensionForFile:fileName course:self.courseName];
    NSString *fileFullName = [fileName stringByAppendingPathExtension:(fileType != nil ? fileType : @"pdf")];
    cell.textLabel.text = fileName;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    
    if ([[THUFileManager defaultManager] fileExistsForName:fileFullName course:self.courseName]) 
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"文件大小:%@, %@",[fileSizeArray objectAtIndex:indexPath.row], @"已下载"];
    } 
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"文件大小:%@, %@",[fileSizeArray objectAtIndex:indexPath.row], @"未下载"];
    }
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
}

#pragma mark - Table view delegate

- (BOOL)isFileTooLarge:(NSString *)fileSize
{
    if ([fileSize hasSuffix:@"M"]) 
    {
        NSUInteger stringLength = fileSize.length;
        NSString *sizeString = [fileSize substringWithRange:NSMakeRange(0, stringLength-2)];
        if ([sizeString floatValue] > 20.0) 
        {
            return NO;
        }
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self isFileTooLarge:[fileSizeArray objectAtIndex:indexPath.row]]) 
    {
        UIAlertView *fileOpenAlert = [[UIAlertView alloc] initWithTitle:@"文件过大" 
                                                                message:@"文件大于20M，请使用电脑打开" 
                                                               delegate:nil 
                                                      cancelButtonTitle:@"好的" 
                                                      otherButtonTitles:nil, nil];
        [fileOpenAlert show];
        return;
    }
    
    NSString *fileName = [[CourseInfo sharedCourseInfo].fileListInfo objectAtIndex:indexPath.row];
    NSString *fileType = [[THUFileManager defaultManager] extensionForFile:fileName course:self.courseName];
    BOOL fileExist = fileType == nil ? NO : YES;
    
    FileContentViewController *controller = [[FileContentViewController alloc] initWithNibName:@"FileContentViewController" bundle:nil CourseName:self.courseName fileName:fileName fileType:fileType index:indexPath.row exist:fileExist];
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
