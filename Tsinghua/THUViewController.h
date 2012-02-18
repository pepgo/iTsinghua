//
//  THUViewController.h
//  Tsinghua
//
//  Created by Xin Chen on 11-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QLoadingView.h"
#import "THUNetworkManager.h"
#import "CourseInfo.h"

/*
 Change Log:
 1. ThuViewController Class:
    THUViewController derives from UIViewController but not the former UITableViewController.
    Since the third level view controllers, for example the HomeworkDetailViewController, which 
    is not the table view controller but can take advantages of many methods in THUViewController.
 
 2. Refresh Button Function:
    Refresh button only appears in the first level of view controllers. The only network request it 
    will send is the course request.
 
 3. NotificationCenter-Based Network Request System:
    The network request begins with method -requestDidStartOfType:url:object, and ends with method
    - requestDidFinish: with a notification object which will notify the controller whether the reuqest
    succeeded or failed. 
    
    3.1 If succeeded, -reloadDataSource will be called to and the table view will be shown.
    3.2 If failed, more work need be done here.
 
 4. New version tag:
    For making the code clearly, everytime a new method, a property or some others added, it should be 
    taged with @since version.
 */

// baseRequestURL:
// Base URL of the Network School.
static NSString *baseRequestURL = @"http://learn.tsinghua.edu.cn";

@interface THUViewController : UIViewController <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSArray *courseNameArray;
    NSInteger selectedIndex;
    NSString *currentCourseName;
    UITableView *mainTableView;
    UITableViewCellStyle cellStyle;
    UIBarButtonItem *logoutButton;
    UIBarButtonItem *refreshButton;
    BOOL connectionFailed;
}

// connectionFailed:
// Boolean value indicates the result of the network connection result.
// @since 1.0.2
@property (assign, nonatomic) BOOL connectionFailed;

// selectedIndex:
// @since 1.0.2
@property (assign, nonatomic) NSInteger selectedIndex;

//@since 2011.12.8
@property (strong, nonatomic) NSString *currentCourseName;

// courseNameArray:
// Array contains the course names, contained in the singleton sharedCourseInfo.
// @since 1.0.1
@property (strong, nonatomic) NSArray *courseNameArray;

// mainTableView
// @since 1.0.3
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

// cellStyle:
// Property defines the table view cell style
// @since 1.0.2
@property (assign, nonatomic) UITableViewCellStyle cellStyle;

// BarButtons:
// @since 1.0.2
@property (strong, nonatomic, readonly) UIBarButtonItem *logoutButton;
@property (strong, nonatomic, readonly) UIBarButtonItem *refreshButton;

// Initializer:
// @since 1.0.3
- (id)initWithIndex:(NSInteger)index courseName:(NSString *)cName;
- (id)initWithCellStyle:(UITableViewCellStyle)cStyle;
- (id)initWithCellStyle:(UITableViewCellStyle)cStyle index:(NSInteger)index; 

// Function:
// Called when configuring the table view cell.
// 
// Note:
// Override this method before using it.
// @since 1.0.1
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// Function:
// Called after the logoutButton pressed. Post the notification to notify the delegate
// performing the view transition between tsinghuaTabBarController view to loginView.
// @since 1.0.0
- (void)logoutButtonPressed;

// Function:
// Called after the refresh button pressed. Re-send the current content request and reload
// the table view or content view;
// @since 1.0.1
- (void)refreshButtonPressed;

// @since 1.0.3
- (void)reloadDataSource;

// Function:
// Called when creating the url request for fetching course info.
// This request is used by the second level of content controllers.
// rString  *string to be replaced
// string   *string to replace the string above
// @since 1.0.1
- (NSString *)requestStringByReplacing:(NSString *)rString withString:(NSString *)string atIndex:(NSInteger)index;

// Function:
// Called when view is loading. The url request for certain view content will be sent.
// This will return YES if the connection finished sucessfully.
// Loading view:    show
// TableView:       hide
// @since 1.0.1 (Method Name changed in @1.0.3)
- (void)requestDidStartOfType:(NSString *)type url:(NSString *)rURL;

// @since 1.0.3
- (void)requestDidFinish:(NSNotification *)notification;

//the applocation support iPad
// @since 1.0.4
//over write the method of defining cell`s height

@end
