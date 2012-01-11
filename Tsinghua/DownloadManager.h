//
//  DownloadManager.h
//  Tsinghua
//
//  Created by Xin Chen on 11-11-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

// @since 1.0.4
//
// Change Log (@1.0.6)
// The root directory'name is set to the user account name

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NetworkManager.h"

// @since 1.0.4
static NSString *thuDownloadFinishNotification = @"thuDownloadFinishNotification";

@interface DownloadManager : NSObject <NetworkManagerDownloadDelegate>
{
    NSString *lastFileName;
    NSString *lastCourseName;
    float downloadProgress;
}

// downloadProgress
// Float value represents the percentage of the downloaded data. This value has a range of [0.0, 1.0].
// @since 1.0.4
@property (assign, nonatomic) float downloadProgress;

// @since 1.0.4
@property (strong, nonatomic) NSString *lastFileName;
@property (strong, nonatomic) NSString *lastCourseName;

// @since 1.0.4
+ (DownloadManager *)sharedManager;

// @since 1.0.4
- (void)startDownload:(NSString *)file forCourse:(NSString *)course withUrl:(NSString *)downloadURL;
// @since 1.0.4
- (void)saveData:(NSData *)fileData forFile:(NSString *)file forCourse:(NSString *)course;
// @since 1.0.4
- (NSData *)loadDataForFile:(NSString *)file course:(NSString *)course error:(NSError **)error;

// Function:
// Search the specific file. If the file exists, view controller can load the data directly.
// @since 1.0.4
- (BOOL)fileIsDownloaded:(NSString *)file forCourse:(NSString *)course;

// Function:
// Delete the downloaded files.
// @since 1.0.5
// - (BOOL)deleteFile:(NSString *)file forCourse:(NSString *)course;

@end
