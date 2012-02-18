//
//  HomeworkDetailViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HomeworkDetailViewController.h"
#import "CourseInfo.h"
#import "THUNetworkManager.h"
#define PI 3.1415

static NSString *baseString = @"http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/";


@implementation HomeworkDetailViewController

@synthesize header;
@synthesize content; 
@synthesize deadline;
@synthesize deadlineString;
@synthesize clockButton;

#pragma mark - 
#pragma mark set up a local notification to the notification center
- (IBAction)notisCurrentHomework:(id)sender {
    
    self.clockButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"homework_alon.png"]];
    
    if (notisCount == 0) {
        NSArray *timeComponentsArray = [deadline.text componentsSeparatedByString:@"-"];
        int year = [[timeComponentsArray objectAtIndex:0] intValue];
        int month = [[timeComponentsArray objectAtIndex:1] intValue];
        int day = [[timeComponentsArray objectAtIndex:2] intValue];
        
        NSDate *today = [NSDate date];
        
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:day];
        [dateComponents setMonth:month];
        [dateComponents setYear:year];
        [dateComponents setHour:12];
        [dateComponents setMinute:0];
        NSDate *date = [calendar dateFromComponents:dateComponents];
        if ([date compare:today] == NSOrderedAscending) {
            NSLog(@"today:%@,date:%@",today,date);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"不能为这次作业设置提醒" message:@"本次作业已经过期或者即将过期" delegate:nil cancelButtonTitle:@"我知道了：）" otherButtonTitles:nil, nil];
            [alert show];
            return;
        } else {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            if (localNotification == nil) {
                return;
            }
            localNotification.fireDate = date;
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"%@%@12小时后将无法提交", nil),self.currentCourseName,header.text];
            localNotification.alertAction = NSLocalizedString(@"前往查看详细信息", nil);
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            NSDictionary *infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.currentCourseName,@"Course Name",header.text,@"Homework Name", nil];
            localNotification.userInfo = infoDictionary;
            localNotification.applicationIconBadgeNumber = 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒设置成功" message:nil delegate:self cancelButtonTitle:@"我知道了：）" otherButtonTitles:nil, nil];
            [alert show];
            notisCount = 1;
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"本次作业的提醒已经设置过了" message:nil delegate:self cancelButtonTitle:@"我知道了：）" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    // Generate the request url string
    NSString *homeworkDetailURL = [[CourseInfo sharedCourseInfo].homeworkDetailURL objectAtIndex:selectedIndex];
    NSString *requestURL = [NSString stringWithFormat:@"%@%@", baseString, homeworkDetailURL];
    [self requestDidStartOfType:thuHomeworkDetailRequest url:requestURL];
    
    deadlineString = [deadline text];
    headString = [header text];
    contentString = [content text];
    
    [super viewDidAppear:animated];
}

- (void)reloadDataSource
{
    // Set the deadline
    self.deadline.text = [[CourseInfo sharedCourseInfo].homeworkDeadline objectAtIndex:selectedIndex];
    
    // Set the homework header
    self.header.text = [CourseInfo sharedCourseInfo].homeworkDetailHead;
    
    // Set the homework content 
    NSString *detailString = [[CourseInfo sharedCourseInfo] homeworkDetailContent];
    
    if (!detailString) {
        self.content.text = @"这次作业没有描述，请前往网络学堂（网页版）下载本次作业的对应文档，或者就是老师没有写任何的作业内容。";
    } else {
        self.content.text = detailString;
    }
    
}

- (void)viewDidLoad
{
    notisCount = 0;
    content.editable = NO;
    [super viewDidLoad];
}

- (void)requestDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqual:thuRequestFinishNotification]) {
        [self reloadDataSource];
    }
    [super requestDidFinish:notification];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [[NSBundle mainBundle] loadNibNamed:@"HomeworkDetailViewController_iPad" owner:self options:nil];
        [self reloadDataSource];
    } else if (UIInterfaceOrientationIsLandscape(orientation)){
        [[NSBundle mainBundle] loadNibNamed:@"HomeworkDetailViewController_iPad_land" owner:self options:nil];
        [self reloadDataSource];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return NO;
    }
}

@end
