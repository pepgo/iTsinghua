//
//  AppDelegate.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "NetworkManager.h"
#import "FileViewController.h"
#import "NotesViewController.h"
#import "HomeworkViewController.h"
#import "SettingViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize loginViewController = _loginViewController;
@synthesize tsinghuaTabBarController = _tsinghuaTabBarController;


- (void)performViewTransitionIn:(BOOL)forIn
{
    // View transition with animation
    CATransition *transition = [CATransition animation];
    transition.duration = 0.75f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [self.window.layer addAnimation:transition forKey:nil];

    if (forIn) {
        [self showTsinghuaView];
    } else {
        [self showLoginView];
        // Do not forget to clear up the former CourseInfo
    }
}

- (void)showLoginView {
    [NetworkManager sharedManager].cookies = nil;
    _loginViewController.userName.text = nil;
    _loginViewController.userPasswords.text = nil;
    whetherLogined = NO;
    [self.tsinghuaTabBarController.view removeFromSuperview];
    NSLog(@"%@",self.loginViewController.nibName);
    NSLog(@"%@",[NSValue valueWithCGRect:self.loginViewController.userName.frame]);
    [self.window addSubview:self.loginViewController.view];
    [self.window.layer removeAllAnimations];
}

- (void)showTsinghuaView 
{    
    if (whetherLogined == NO) 
    {
        HomeworkViewController *homeworkViewController = [[HomeworkViewController alloc] initWithCellStyle:UITableViewCellStyleValue1];
        UINavigationController *controller_1 = [[UINavigationController alloc] initWithRootViewController:homeworkViewController];
        homeworkViewController.navigationItem.title = @"作业";
        controller_1.tabBarItem.image = [UIImage imageNamed:@"tab_1.png"];
        controller_1.navigationBar.tintColor = [UIColor blackColor];

        NotesViewController *noteViewController = [[NotesViewController alloc] init];
        UINavigationController *controller_2 = [[UINavigationController alloc] initWithRootViewController:noteViewController];
        noteViewController.navigationItem.title = @"公告";
        controller_2.tabBarItem.image = [UIImage imageNamed:@"tab_2.png"];
        controller_2.navigationBar.tintColor = [UIColor blackColor];

        FileViewController *fileViewController = [[FileViewController alloc] init];
        UINavigationController *controller_3 = [[UINavigationController alloc] initWithRootViewController:fileViewController];
        fileViewController.navigationItem.title = @"课件";
        controller_3.tabBarItem.image = [UIImage imageNamed:@"tab_3.png"];
        controller_3.navigationBar.tintColor = [UIColor blackColor];
        
        SettingViewController *settingViewController;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController_iPad" bundle:nil];
            } else {
                settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController_iPad_land" bundle:nil];
            }
        } else {
            settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController_iPhone" bundle:nil];
        }
        settingViewController.navigationItem.title = @"更多";
        UINavigationController *controller_4 = [[UINavigationController alloc] initWithRootViewController:settingViewController];
        controller_4.tabBarItem.image = [UIImage imageNamed:@"tab_4.png"];
        controller_4.tabBarItem.title = nil;
        controller_4.navigationBar.tintColor = [UIColor blackColor];
        
        [self.tsinghuaTabBarController setViewControllers:[NSArray arrayWithObjects:controller_1, controller_2, controller_3, controller_4, nil]];
        whetherLogined = YES;
    }    
    
    [self.loginViewController.view removeFromSuperview];
    [self.window addSubview:self.tsinghuaTabBarController.view];
    [self.window.layer removeAllAnimations];
}

- (void)logoutRequestDidReceived {
    [self performViewTransitionIn:NO];
}

- (UIViewController *)mainViewController
{
    if (whetherLogined == YES) {
        return self.tsinghuaTabBarController;
    }
    return self.loginViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutRequestDidReceived) name:@"Logout" object:nil];
    NSLog(@"iTsinghua Application Version:%@", self.appVersion);
    
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    UILocalNotification *localNotification;
    if ((localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey])) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[localNotification.userInfo objectForKey:@"Course Name"] message:[localNotification.userInfo objectForKey:@"Homework Name"] delegate:nil cancelButtonTitle:@"我知道了：）" otherButtonTitles:nil, nil];
        [alert show];
        [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
    }
    
    localNotisArray = [[NSMutableArray alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController_iPad" bundle:nil];
        } else {
            self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController_iPad_land" bundle:nil];
        }
    } else {
        self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController_iPhone" bundle:nil];
    }
    
    self.tsinghuaTabBarController = [[UITabBarController alloc] init];
    
    whetherLogined = NO;
    [self showLoginView];
    
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.autoresizesSubviews = YES;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSString *)appVersion
{
    return @"1.0.5";
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (application.applicationState == UIApplicationStateInactive ) {
        [localNotisArray addObject:notification.userInfo];
        return;
    }
    if(application.applicationState == UIApplicationStateActive ) { 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[notification.userInfo objectForKey:@"Course Name"] message:[notification.userInfo objectForKey:@"Homework Name"] delegate:nil cancelButtonTitle:@"我知道了：）" otherButtonTitles:nil, nil];
        [alert show];
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
        return;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    for (NSDictionary *courseInfo in localNotisArray) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[courseInfo objectForKey:@"Course Name"] message:[courseInfo objectForKey:@"Homework Name"] delegate:nil cancelButtonTitle:@"我知道了：）" otherButtonTitles:nil, nil];
        [alert show];
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [localNotisArray removeAllObjects];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
