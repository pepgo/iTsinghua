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
#import "TFHpple.h"

@interface HomeworkViewController (Private)

- (void)getNotesAndFileCount;

@end

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
    
//    the [getNotesAndFileCount] method which will running in the background
//    [self performSelectorInBackground:@selector(getNotesAndFileCount) withObject:nil];
    
}


//the method is used to check whether there is any new note or file in each course
//it will be invoke in the background thread while the homeWorkViewController has been loaded
//I blank this method since I have some problem about [reloadData] method in the fileViewController
//and NotesViewController. I will fix this problem in the nect version
- (void)getNotesAndFileCount {
    NSMutableArray *noteCounterArray = [[NSMutableArray alloc] init];
    NSString *requestURL;    
    int courseIndex = 0;
    for (int i = 0; i < courseNameArray.count; i++) {
        requestURL = [self requestStringByReplacing:@"/lesson/student/course_locate.jsp" 
                                         withString:@"/public/bbs/getnoteid_student.jsp" 
                                            atIndex:i];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURL]];
        
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        
        //get note basic info
        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr/td/a"];
        [noteCounterArray insertObject:[NSNumber numberWithInt:[elements count]] atIndex:courseIndex];
        courseIndex++;
    }
    [[CourseInfo sharedCourseInfo] setNotesCount:noteCounterArray];

    NSMutableArray *fileCountArray = [[NSMutableArray alloc] init];
    courseIndex = 0;
    TFHppleElement *element;
    NSRange range;
    int tempFileCount;
    for (int i = 0; i < courseNameArray.count; i++) {
        requestURL = [self requestStringByReplacing:@"/lesson/student/course_locate.jsp" 
                                         withString:@"/lesson/student/download.jsp" 
                                            atIndex:i];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURL]];
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr/td/a"];
        NSUInteger length = [elements count];
        NSUInteger serialNumber = 0;
        tempFileCount = 0;
        for (NSUInteger j = 0; j < length; j++) {
            element = (TFHppleElement *)[elements objectAtIndex:j];
            range = [[element content] rangeOfString:@"序"];
            if (range.location == 0 && [element content] != NULL) {
                serialNumber += 1;
                if (serialNumber ==3) {
                    break;
                }
            }
            if (j > 3) {
                tempFileCount++;
            }
        }
        [fileCountArray insertObject:[NSNumber numberWithInt:tempFileCount] atIndex:courseIndex];
        courseIndex++;
    }
    [[CourseInfo sharedCourseInfo] setFileCount:fileCountArray];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"COUNT_SUCCESSFULLY" object:nil];
    
    for (int i = 0; i < courseNameArray.count; i++) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[noteCounterArray objectAtIndex:i]] forKey:[NSString stringWithFormat:@"Note-%@",[courseNameArray objectAtIndex:i]]];
        NSLog(@"note count:%@",[noteCounterArray objectAtIndex:i]);
        NSLog(@"note:%@",[NSString stringWithFormat:@"%@",[noteCounterArray objectAtIndex:i]]);
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[fileCountArray objectAtIndex:i]] forKey:[NSString stringWithFormat:@"File-%@",[courseNameArray objectAtIndex:i]]];
    }
    
    NSLog(@"count successfully");
    
    if (noteCounterArray.count > 0) {
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:@"New"];
    }
    if (fileCountArray.count > 0) {
        [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:@"New"];
    }
    if (noteCounterArray.count > 0) {
        [NSThread exit];
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
