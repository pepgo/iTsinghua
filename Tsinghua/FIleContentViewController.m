//
//  FIleContentViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FIleContentViewController.h"
#import "NetworkManager.h"

@implementation FIleContentViewController

@synthesize fileContentView;
@synthesize MIMEType;
@synthesize documentData;
@synthesize courseName;
@synthesize fileName;
@synthesize index;

- (id)initWithCourseName:(NSString *)course fileName:(NSString *)file index:(NSInteger)sIndex
{
    if (self = [super init]) {
        self.courseName = course;
        self.fileName = file;
        self.index = sIndex;
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

- (void)viewDidAppear:(BOOL)animated
{
    // If the document data is available already, load the data directly; Otherwise, send the file 
    // request to start downloading. 
    if ([[DownloadManager sharedManager] fileIsDownloaded:self.fileName forCourse:self.courseName]) {
        NSError *error = nil;
        self.documentData = [[DownloadManager sharedManager] loadDataForFile:self.fileName course:self.courseName error:&error];
        if (error != nil) {
            // Error handlements here
            NSLog(@"Error occured when loading data. Error: %@", [error localizedDescription]);
        }
        NSLog(@"data length: %d", self.documentData.length);
        [self webViewWillStartLoadingWithType:self.MIMEType];
    } else {
        NSArray *array = [NSArray arrayWithArray:[CourseInfo sharedCourseInfo].fileLinkURLInfo];
        NSString *url = [@"http://learn.tsinghua.edu.cn" stringByAppendingString:[array objectAtIndex:self.index]];
        [[DownloadManager sharedManager] startDownload:self.fileName forCourse:self.courseName withUrl:url];
    }
    [super viewDidAppear:animated];
}

- (void)webViewWillStartLoadingWithType:(NSString *)type
{
    NSAssert(self.documentData != nil, @"The data file is nil or corrupted!");
    // Set the webview to load the data
    [self.fileContentView loadData:self.documentData MIMEType:type textEncodingName:textEncoding baseURL:nil];
}

- (void)downloadDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqualToString:thuDownloadFinishNotification]) {
        NSError *error = nil;
        self.documentData = [[DownloadManager sharedManager] loadDataForFile:self.fileName course:self.courseName error:&error];
        if (error != nil) {
            // Error handlement here
        }
        [self webViewWillStartLoadingWithType:self.MIMEType];
    }
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDidFinish:) 
                                                 name:thuDownloadFinishNotification object:nil];
    // Set the PDF to be the default format. 
    self.MIMEType = format_pdf;
    self.fileContentView.scalesPageToFit = YES;
    self.title = self.courseName;
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"WebView did start loading data, type:%@", self.MIMEType);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"WebView did finish loading data, type:%@", self.MIMEType);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([self.MIMEType isEqual:format_pdf]) {
        self.MIMEType = format_doc;
    } else if ([self.MIMEType isEqual:format_doc]) {
        self.MIMEType = format_ppt;
    } else if ([self.MIMEType isEqual:format_ppt]) {
        self.MIMEType = format_xls;
    } else if ([self.MIMEType isEqual:format_xls]) {
        // XLS is the last possible format to be tested.
        UIAlertView *formatAlert = [[UIAlertView alloc] initWithTitle:@"" 
                                                              message:@"文件格式未知或不被支持，无法解析，请使用电脑打开该文件!" 
                                                             delegate:self 
                                                    cancelButtonTitle:@"好的" 
                                                    otherButtonTitles:nil, nil];
        [formatAlert show];
        return;
    }
    [self webViewWillStartLoadingWithType:self.MIMEType];
}

#pragma mark - UIAlertView Delegate

- (void)alertViewCancel:(UIAlertView *)alertView
{
    // Since the file is unable to be parsed, no content will be shown in this view.
    // So pop back to the last view controller automaticaly
    [self.navigationController popViewControllerAnimated:YES];
}

@end
