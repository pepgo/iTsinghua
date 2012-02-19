//
//  THUDownloadManager.h
//  Tsinghua
//
//  Created by Xin Chen on 11-11-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

// @since 1.4
//
// Change Log (@1.6)
// The root directory'name is set to the user account name

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "THUNetworkManager.h"

@interface THUDownloadManager : NSObject <THUNetworkManagerDownloadDelegate>
{
    NSString *lastFileName;
    NSString *lastCourseName;
    float downloadProgress;
}

// downloadProgress
// Float value represents the percentage of the downloaded data. This value has a range of [0.0, 1.0].
// @since 1.4
@property (assign, nonatomic) float downloadProgress;
// @since 2.1
@property (assign, nonatomic) float downloadRate;

// @since 1.4
@property (strong, nonatomic) NSString *lastFileName;
@property (strong, nonatomic) NSString *lastCourseName;

// @since 1.4
+ (THUDownloadManager *)sharedManager;

// @since 1.4
- (void)startDownload:(NSString *)file forCourse:(NSString *)course withUrl:(NSString *)downloadURL;

@end


