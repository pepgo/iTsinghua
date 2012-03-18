//
//  THUTabBarController.m
//  Tsinghua
//
//  Created by Xin Chen on 12-2-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "THUTabBarController.h"
#import "FileViewController.h"
#import "NotesViewController.h"
#import "HomeworkViewController.h"
#import "SettingViewController.h"
#import "QLoadingView.h"
#import "THUNotifications.h"

@implementation THUTabBarController

- (id)init
{
    if (self = [super init]) 
    {
        // Alloc the view controllers for the tabBarController
        HomeworkViewController *homeworkViewController = [[HomeworkViewController alloc] initWithCellStyle:UITableViewCellStyleSubtitle];
        homeworkViewController.title = @"作业";
        UINavigationController *homeworkNavController = [[UINavigationController alloc] initWithRootViewController:homeworkViewController];
        homeworkNavController.title = nil;
        homeworkNavController.tabBarItem.image = [UIImage imageNamed:@"tab_1.png"];
        
        NotesViewController *noteViewController = [[NotesViewController alloc] initWithCellStyle:UITableViewCellStyleSubtitle];
        noteViewController.title = @"公告";
        UINavigationController *noteNavController = [[UINavigationController alloc] initWithRootViewController:noteViewController];
        noteNavController.title = nil;
        noteNavController.tabBarItem.image = [UIImage imageNamed:@"tab_2.png"];
        
        FileViewController *fileViewController = [[FileViewController alloc] initWithCellStyle:UITableViewCellStyleSubtitle];
        fileViewController.title = @"课件";
        UINavigationController *fileNavController = [[UINavigationController alloc] initWithRootViewController:fileViewController];
        fileNavController.title = nil;
        fileNavController.tabBarItem.image = [UIImage imageNamed:@"tab_3.png"];
        
        SettingViewController *settingViewController = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController_iPad" bundle:nil];
            } else {
                settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController_iPad_land" bundle:nil];
            }
        } else {
            settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController_iPhone" bundle:nil];
        }
        settingViewController.title = @"更多";
        UINavigationController *settingNavController = [[UINavigationController alloc] initWithRootViewController:settingViewController];
        settingNavController.title = nil;
        settingNavController.tabBarItem.image = [UIImage imageNamed:@"tab_4.png"];
        
        self.viewControllers = [NSArray arrayWithObjects:homeworkNavController, noteNavController, fileNavController, settingNavController, nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)logoutNotificationReceived:(NSNotification *)notification
{
    //clean up all the course info
    [[CourseInfo sharedCourseInfo] clearUpCourseInfo];

    CATransition *fadeTransition = [CATransition animation];
    fadeTransition.duration = 0.5f;
    fadeTransition.type = kCATransitionFade;
    fadeTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.navigationController.view.layer addAnimation:fadeTransition forKey:@"fadeTransition"];
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [QLoadingView showWithInfo:@"正在载入数据..."];
    
    // Method for LogoutNotification received
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotificationReceived:) 
                                                 name:thuLogoutNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
