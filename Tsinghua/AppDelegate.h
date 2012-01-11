//
//  AppDelegate.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

/*
 // ROAD MAP 
 //
 // 1.      Send the network request after the view transition but not before the view transition.
 // 1.1     ViewController Change (5/9)
 // 1.2     NetworkManager Change (0/9)
 // 1.3     Synchronous request or asynchronous request?
 //
 // 2.      Manage diff errors when sending network request
 // 2.1     Add error management into NetworkManager
 // 2.2     Methods to deal with diff errors for view controllers
 //
 // 3.      Add TaskManager or CurriculumManager
 // 
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UITabBarController *_tsinghuaTabBarController;
    LoginViewController *_loginViewController;
    BOOL whetherLogined;

    NSMutableArray *localNotisArray;
    
    NSString *appVersion;
}

@property (strong, nonatomic) UITabBarController *tsinghuaTabBarController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) NSString *appVersion;

- (void)showLoginView;
- (void)showTsinghuaView;
- (UIViewController *)mainViewController;

// forIn: if the transition is from loginViewController to tsinghuaTabBarController,
// the value is YES, otherwise the value is NO;
- (void)performViewTransitionIn:(BOOL)forIn;

@end
