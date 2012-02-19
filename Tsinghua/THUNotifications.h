//
//  THUNotifications.h
//  Tsinghua
//
//  Created by Xin Chen on 12-2-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

static NSString *thuLoginNotification = @"thuLoginNotification";

// This notification will be post when user presses logout button
static NSString *thuLogoutNotification = @"thulogoutNotification";

// This notification will be post when user browses all the help scroll views. 
static NSString *thuEndShowTipsNotification = @"thuEndShowTipsNotification";

// This notification will be post when network connection time out
static NSString *thuTimeOutNotification = @"thuTimeOutNotification";

// This notification will be post when network connection finishes sucessfully.
static NSString *thuRequestFinishNotification = @"thuRequestFinishNotification";

// This notification will be post when user account and password is verified.
static NSString *thuLoginSucceedNotification = @"thuLoginSucceedNotification";

// This notification will be post when user login verifying fails.
static NSString *thuLoginFailedNotification = @"thuLoginFailedNotification";

// This notification will be post when a file is downloaded sucessfully.
static NSString *thuDownloadFinishNotification = @"thuDownloadFinishNotification";

// This notification will be post when download progress changes more than 2%. 
static NSString *thuDownloadProgressChangeNotification = @"thuDownloadProgressChangeNotification";
