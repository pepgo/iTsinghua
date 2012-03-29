//
//  THUViewController.m
//  Tsinghua
//
//  Created by Xin Chen on 11-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "THUViewController.h"
#import "CourseInfo.h"
#import "THUNotifications.h"

@implementation THUViewController

@synthesize courseNameArray;
@synthesize cellStyle;
@synthesize logoutButton;
@synthesize refreshButton;
@synthesize connectionFailed;
@synthesize selectedIndex;
@synthesize currentCourseName;
@synthesize mainTableView;

- (id)initWithIndex:(NSInteger)index courseName:(NSString *)cName
{
    if (self) 
    {
        self.selectedIndex = index;
        self.currentCourseName = cName;
    }
    return self;
}

- (id)initWithCellStyle:(UITableViewCellStyle)cStyle
{
    if (self = [super init]) {
        self.cellStyle = cStyle;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewInfo) name:@"COUNT_SUCCESSFULLY" object:nil];
    }
    return self;
}

- (id)initWithCellStyle:(UITableViewCellStyle)cStyle index:(NSInteger)index
{
    if (self = [super init]) {
        self.cellStyle = cStyle;
        self.selectedIndex = index;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the logout button on the right side of the navigatin bar 
    self.navigationItem.rightBarButtonItem = self.logoutButton;
    
    // 
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mainTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizesSubviews = YES;
    self.mainTableView.autoresizesSubviews = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // Observe the notification of request finish and request time out
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestDidFinish:) name:thuTimeOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestDidFinish:) name:thuRequestFinishNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return NO;
    } else {
        return YES;
    }
}

- (void)requestDidStartOfType:(NSString *)type url:(NSString *)rURL
{
    [self.view setHidden:YES];                                                 
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;    
    [QLoadingView showWithInfo:@"正在载入数据..."];
    [[THUNetworkManager sharedManager] sendNetworkRequest:type url:rURL object:nil];          
}

- (void)requestDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqualToString:thuTimeOutNotification]) {
        UIAlertView *requestError = [[UIAlertView alloc] initWithTitle:@"超时" 
                                                               message:@"连接超时，请检查您的网络" 
                                                              delegate:nil 
                                                     cancelButtonTitle:@"知道了" 
                                                     otherButtonTitles:nil, nil];
        [requestError show];
    }
    
    [QLoadingView hideWithAnimated:YES];               
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    [self.view setHidden:NO];                                                
}

- (UIBarButtonItem *)logoutButton
{
    if (logoutButton == nil) {
        logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"注销" 
                                                        style:UIBarButtonItemStyleBordered 
                                                       target:self 
                                                       action:@selector(logoutButtonPressed)];
    }
    return logoutButton;
}

- (UIBarButtonItem *)refreshButton
{
    if (refreshButton == nil) {
        refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                      target:self 
                                                                      action:@selector(refreshButtonPressed)];
    }
    return refreshButton;
}

- (NSString *)requestStringByReplacing:(NSString *)rString withString:(NSString *)string atIndex:(NSInteger)index
{
    // Create the base string.
    // The base string has two parts. The first is the base url of the thu net school.
    // The second part is the course url stored in the course info dictionary.
    NSString *baseString = [baseRequestURL stringByAppendingString:[[CourseInfo sharedCourseInfo].courseURL objectAtIndex:index]];
    // Replacing some part of the string to form the correct url
    NSString *requestString = [baseString stringByReplacingOccurrencesOfString:rString withString:string];
    return requestString;
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//if the user have no course then it will not show any info
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self haveCourse]) {
        return [self.courseNameArray count];

    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Public cell init calls
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:self.cellStyle reuseIdentifier:cellIdentifier];
    }
    
    // Custom cell configuration 
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Override this method before imeplementing it.
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UIActionSheet Delegate

- (void)logoutButtonPressed
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:self 
                                                    cancelButtonTitle:@"取消" 
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:@"确认退出", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)refreshButtonPressed
{
    // Since the view transition happens before sending the request, the last request
    // url is certainly to be the url of this view. So we store the request type and 
    // the url and re-use them when pressing refresh button.
    [self requestDidStartOfType:[THUNetworkManager sharedManager].lastRequestType 
                            url:[THUNetworkManager sharedManager].lastRequestURL];
}

- (void)reloadDataSource
{
   [CourseInfo sharedCourseInfo].courseName = nil; 
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.firstOtherButtonIndex) 
    {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:thuLogoutNotification object:nil]];
    }
}

- (void)reloadMainTableView {
    [self.mainTableView reloadData];
    [self.mainTableView setNeedsDisplay];
}

- (void)getNewInfo {
    
}

- (BOOL)haveCourse {
    return [[CourseInfo sharedCourseInfo] courseName].count > 0 ? YES:NO;
}

@end
