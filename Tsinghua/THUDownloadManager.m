//
//  THUDownloadManager.m
//  Tsinghua
//
//  Created by Xin Chen on 11-11-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "THUDownloadManager.h"
#import "THUAccountManager.h"
#import "THUFileManager.h"
#import "THUNotifications.h"

@implementation THUDownloadManager

@synthesize downloadProgress;
@synthesize downloadRate;
@synthesize lastFileName;
@synthesize lastCourseName;

+ (THUDownloadManager *)sharedManager
{
    // See comment in header.
    static THUDownloadManager * cTHUDownloadManager;
    
    // This can be called on any thread, so we synchronise.  We only do this in 
    // the sTHUNetworkManager case because, once sTHUNetworkManager goes non-nil, it can 
    // never go nil again.
    
    if (cTHUDownloadManager == nil) {
        @synchronized (self) {
            cTHUDownloadManager = [[THUDownloadManager alloc] init];
            assert(cTHUDownloadManager != nil);
        }
        [[THUNetworkManager sharedManager] setDelegate:cTHUDownloadManager];
    }
    
    return cTHUDownloadManager;
}

- (void)startDownload:(NSString *)file forCourse:(NSString *)course withUrl:(NSString *)downloadURL
{
    // Notify the network manager to start downloading the file
    [[THUNetworkManager sharedManager] sendNetworkRequest:thuFileDownloadRequest url:downloadURL object:nil];
    
    // Save the file name and course name
    self.lastFileName = file;
    self.lastCourseName = course;
}

#pragma mark - THUNetworkManagerDownload Delegate

- (void)downloadConnection:(NSURLConnection *)connection inProgress:(float)percentage
{
    if (connection != nil) 
    {
        if (percentage - self.downloadProgress >= 0.02f) 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:thuDownloadProgressChangeNotification object:nil];
            [self setDownloadProgress:percentage];
        }
    }
}

- (void)downloadConnection:(NSURLConnection *)connection receiveDataRate:(float)rate
{
    [self setDownloadRate:rate];
}

- (void)downloadConnectionDidFinish:(NSURLConnection *)connection data:(NSData *)data
{
    // Save the downloaded data
    [[THUFileManager defaultManager] saveData:data name:self.lastFileName course:self.lastCourseName];
    
    // Post the download finish notification
    NSNotification *notification = [NSNotification notificationWithName:thuDownloadFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)downloadConnectionDidStart:(NSURLConnection *)connection
{
    [self setDownloadProgress:0.0f];
}

@end
