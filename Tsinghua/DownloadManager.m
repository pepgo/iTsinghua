//
//  DownloadManager.m
//  Tsinghua
//
//  Created by Xin Chen on 11-11-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DownloadManager.h"

@implementation DownloadManager

@synthesize downloadProgress;
@synthesize lastFileName;
@synthesize lastCourseName;

+ (DownloadManager *)sharedManager
{
    // See comment in header.
    static DownloadManager * cDownloadManager;
    
    // This can be called on any thread, so we synchronise.  We only do this in 
    // the sNetworkManager case because, once sNetworkManager goes non-nil, it can 
    // never go nil again.
    
    if (cDownloadManager == nil) {
        @synchronized (self) {
            cDownloadManager = [[DownloadManager alloc] init];
            assert(cDownloadManager != nil);
        }
        [[NetworkManager sharedManager] setDelegate:cDownloadManager];
    }
    
    return cDownloadManager;
}

- (void)startDownload:(NSString *)file forCourse:(NSString *)course withUrl:(NSString *)downloadURL
{
    // Notify the network manager to start downloading the file
    [[NetworkManager sharedManager] sendNetworkRequest:thuFileDownloadRequest url:downloadURL object:nil];
    
    // Save the file name and course name
    self.lastFileName = file;
    self.lastCourseName = course;
}

- (NSString *)applicationDirectory
{
    NSString *accountName = [[NSUserDefaults standardUserDefaults] valueForKey:@"current_account"];
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] 
            stringByAppendingPathComponent:accountName];
}

- (void)saveData:(NSData *)fileData forFile:(NSString *)file forCourse:(NSString *)course
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Generate the file directory
    NSString *courseDir = [[self applicationDirectory] stringByAppendingPathComponent:course];
    
    if ([fileManager createDirectoryAtPath:courseDir withIntermediateDirectories:YES attributes:nil error:NULL] == NO) {
        // Failed to create the directory. 
    }
    
    // Use a txt file to store the binary data
    NSString *fileDir = [[courseDir stringByAppendingPathComponent:file] stringByAppendingPathExtension:@"txt"];
    
    // Convert the file path to the standard url
    NSURL *fileURL = [NSURL fileURLWithPath:fileDir];
    
    // Write the file data to the directory and check.
    NSError *error = nil;
    [fileData writeToURL:fileURL options:NSDataWritingAtomic error:&error];
    if (error != nil) {
        // Error handling
    }
}

- (BOOL)fileIsDownloaded:(NSString *)file forCourse:(NSString *)course
{
    // Generate the file directory
    NSString *courseDir = [[self applicationDirectory] stringByAppendingPathComponent:course];
    NSString *fileDir = [courseDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", file]];
    return [[NSFileManager defaultManager] fileExistsAtPath:fileDir];
}

- (NSData *)loadDataForFile:(NSString *)file course:(NSString *)course error:(NSError *__autoreleasing *)error
{
    // Generate the file directory url
    NSString *courseDir = [[self applicationDirectory] stringByAppendingPathComponent:course];
    NSString *fileDir = [courseDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", file]];
    NSURL *fileURL = [NSURL fileURLWithPath:fileDir];
    
    // Read the data safely
    NSError *readError = nil;
    NSData *fileData = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingUncached error:&readError];
    if (readError != nil || fileData == nil) {
        *error = readError;
        NSLog(@"Error reading file! Error:%@", readError.localizedDescription);
        return nil;
    }
    return fileData;
}

#pragma mark - NetworkManagerDownload Delegate

- (void)downloadConnection:(NSURLConnection *)connection inProgress:(float)percentage
{
    if (connection != nil) {
        self.downloadProgress = percentage;
    }
}

- (void)downloadConnectionDidFinish:(NSURLConnection *)connection data:(NSData *)data
{
    // Hide the download progress view
    
    // Save the downloaded data
    [self saveData:data forFile:self.lastFileName forCourse:self.lastCourseName];
    
    // Post the download finish notification
    NSNotification *notification = [NSNotification notificationWithName:thuDownloadFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)downloadConnectionDidStart:(NSURLConnection *)connection
{
    // Show the download progress view
    
    NSLog(@"start download!");
}

@end
