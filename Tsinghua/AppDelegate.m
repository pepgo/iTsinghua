//
//  AppDelegate.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "THUNetworkManager.h"
#import "LoginViewController.h"
#import "THUTabBarController.h"
#import "QLoadingView.h"
#import "THUNotifications.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navController = _navController;
@synthesize localNotificationsArray = _localNotificationsArray;



- (void)loginNotificationReceived:(NSNotification *)notification
{
    THUTabBarController *thuRootViewController = [[THUTabBarController alloc] init];
    [QLoadingView hideWithAnimated:NO];
    
//    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navController.view cache:YES];
//    [UIView setAnimationDuration:0.6];
//    [self.navController pushViewController:thuRootViewController animated:YES];
//    [UIView commitAnimations];
    
    CATransition *fadeTransition = [CATransition animation];
    fadeTransition.duration = 1.0f;
    fadeTransition.type = kCATransitionFade;
    fadeTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];// kCAMediaTimingFunctionEaseIn];
    [self.navController.view.layer addAnimation:fadeTransition forKey:@"fadeTransition"];
    [self.navController pushViewController:thuRootViewController animated:NO];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Method for LoginNotification received
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginNotificationReceived:) 
                                                 name:thuLoginNotification object:nil];
    
    UILocalNotification *localNotification = nil;
    if ((localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey])) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[localNotification.userInfo objectForKey:@"Course Name"] 
                                                        message:[localNotification.userInfo objectForKey:@"Homework Name"] 
                                                       delegate:nil 
                                              cancelButtonTitle:@"我知道了：）" 
                                              otherButtonTitles:nil, nil];
        [alert show];
        [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
    }
    
    // Alloc the navigation controller
    self.navController = [[UINavigationController alloc] init];
    
    // Add the navigation controller into the UIWindow view controller stack
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window addSubview:self.navController.view];
    
    LoginViewController *loginViewController = [LoginViewController alloc];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) 
            loginViewController = [loginViewController initWithNibName:@"LoginViewController_iPad" bundle:nil];
        else 
            loginViewController = [loginViewController initWithNibName:@"LoginViewController_iPad_land" bundle:nil];
        else 
            loginViewController = [loginViewController initWithNibName:@"LoginViewController_iPhone" bundle:nil];
    // Push to the login view
    [self.navController pushViewController:loginViewController animated:YES];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification 
{
    if (application.applicationState == UIApplicationStateInactive ) 
    {
        if (self.localNotificationsArray == nil) {
            self.localNotificationsArray = [NSMutableArray array];
        }
        [self.localNotificationsArray addObject:notification.userInfo];
    }
    else if(application.applicationState == UIApplicationStateActive ) 
    { 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[notification.userInfo objectForKey:@"Course Name"] 
                                                        message:[notification.userInfo objectForKey:@"Homework Name"] 
                                                       delegate:nil 
                                              cancelButtonTitle:@"我知道了：）" 
                                              otherButtonTitles:nil, nil];
        [alert show];
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    for (NSDictionary *courseInfo in self.localNotificationsArray) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[courseInfo objectForKey:@"Course Name"] 
                                                        message:[courseInfo objectForKey:@"Homework Name"] 
                                                       delegate:nil 
                                              cancelButtonTitle:@"我知道了：）" 
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // Remove the old notification objects
    [self.localNotificationsArray removeAllObjects];
}

@end
