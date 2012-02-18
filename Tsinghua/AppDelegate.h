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
 // 1.2     THUNetworkManager Change (0/9)
 // 1.3     Synchronous request or asynchronous request?
 //
 // 2.      Manage diff errors when sending network request
 // 2.1     Add error management into THUNetworkManager
 // 2.2     Methods to deal with diff errors for view controllers
 //
 // 3.      Add TaskManager or CurriculumManager
 // 
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class THUTabBarController;
@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> 
{    
    UINavigationController *_navController;
    NSMutableArray *_localNotificationsArray;
}

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) NSMutableArray *localNotificationsArray;
@property (strong, nonatomic) UIWindow *window;

@end
