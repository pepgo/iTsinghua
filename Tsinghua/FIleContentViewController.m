//
//  FIleContentViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FileContentViewController.h"
#import "THUNetworkManager.h"
#import "THUFileManager.h"

@implementation FileContentViewController

@synthesize fileContentView;
@synthesize downloadSlider;
@synthesize waitingLabel;
@synthesize downloadRateLabel;
@synthesize MIMEType;
@synthesize documentData;
@synthesize courseName;
@synthesize fileName;
@synthesize index;

- (id)initWithCourseName:(NSString *)course fileName:(NSString *)file index:(NSInteger)sIndex
{
    if (self = [super init]) 
    {
        self.courseName = course;
        self.fileName = [file stringByAppendingPathExtension:@"pdf"];
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
    if ([[THUFileManager defaultManager] fileExistsForName:self.fileName course:self.courseName] == YES) 
    {
        NSError *error = nil;
        self.documentData = [[THUFileManager defaultManager] loadDataForFileName:self.fileName course:self.courseName error:&error];
        if (error != nil) 
        {
            NSLog(@"Error occured when loading data. Error: %@", [error localizedDescription]);
        }
        [self webViewWillStartLoadingWithType:self.MIMEType];
        
        // Hide the download sliderbar and waiting label
        [self.downloadSlider setHidden:YES];
        [self.waitingLabel setHidden:YES];
        [self.downloadRateLabel setHidden:YES];
    } 
    else 
    {
        NSArray *array = [NSArray arrayWithArray:[CourseInfo sharedCourseInfo].fileLinkURLInfo];
        NSString *url = [@"http://learn.tsinghua.edu.cn" stringByAppendingString:[array objectAtIndex:self.index]];
        [[THUDownloadManager sharedManager] startDownload:self.fileName forCourse:self.courseName withUrl:url];
        
        // Show the download sliderbar and waiting label
        [self.downloadSlider setHidden:NO];
        [self.waitingLabel setHidden:NO];
        [self.downloadRateLabel setHidden:NO];
    }
    
    [super viewWillAppear:animated];
}

- (void)downloadProgressDidChange:(NSNotification *)notification
{
    float progress = [THUDownloadManager sharedManager].downloadProgress;
    float rate = [THUDownloadManager sharedManager].downloadRate;
    self.downloadSlider.value = progress;
    self.downloadRateLabel.text = [NSString stringWithFormat:@"下载速度: %.2lf KB/s", rate];
}

- (void)webViewWillStartLoadingWithType:(NSString *)type
{
    NSAssert(self.documentData != nil, @"The data file is nil or corrupted!");
    
    NSData *fileSubData = [self.documentData subdataWithRange:NSMakeRange(0, 8)];
    NSString *dataHeaderString = [fileSubData description];
    if ([dataHeaderString isEqualToString:PDFHeaderString]) 
    {
        // Load the PDF file directly
        [self.fileContentView loadData:self.documentData MIMEType:Format_PDF textEncodingName:textEncoding baseURL:nil];
    }
    else
    {
        /*
         [[THUFileManager defaultManager] setFile:self.fileName newExtension:@"doc"];
         [self.fileContentView loadData:self.documentData MIMEType:type textEncodingName:textEncoding baseURL:nil];
         */
    }
}

- (void)downloadDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqualToString:thuDownloadFinishNotification]) 
    {
        NSError *error = nil;
        self.documentData = [[THUFileManager defaultManager] loadDataForFileName:self.fileName course:self.courseName error:&error];
        if (error != nil) 
        {
            // Error handlement here
            UIAlertView *readDataAlert = [[UIAlertView alloc] initWithTitle:@"数据读取出现错误" 
                                                                    message:@"是否重新下载？" 
                                                                   delegate:self 
                                                          cancelButtonTitle:@"否" 
                                                          otherButtonTitles:@"是", nil];
            [readDataAlert show];
        }
        [self webViewWillStartLoadingWithType:self.MIMEType];
        
        // Hide the download progress slider
        [[NSNotificationCenter defaultCenter] removeObserver:self name:thuDownloadProgressChangeNotification object:nil];
        [self.downloadSlider setHidden:YES];
        [self.waitingLabel setHidden:YES];
        [self.downloadRateLabel setHidden:YES];
    }
}

- (void)viewWillPop
{
    [[THUNetworkManager sharedManager] cancelCurrentRequest];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    // Observe the download finish notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDidFinish:) 
                                                 name:thuDownloadFinishNotification object:nil];
    // Observe the download progress notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgressDidChange:) 
                                                 name:thuDownloadProgressChangeNotification object:nil];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" 
                                                                   style:UIBarButtonItemStyleBordered 
                                                                  target:self 
                                                                  action:@selector(viewWillPop)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Set the PDF to be the default format. 
    self.MIMEType = Format_DOC;
    self.fileContentView.scalesPageToFit = YES;
    self.title = self.courseName;
    
    // Configure the donwload slider
    self.downloadSlider.userInteractionEnabled = NO;
    self.downloadSlider.maximumValue = 1.0f;
    self.downloadSlider.minimumValue = 0.0f;
    self.downloadSlider.continuous = YES;
    self.downloadSlider.value = 0.0f;
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - UIWebView Delegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([self.MIMEType isEqualToString:Format_DOC]) 
    {
        self.MIMEType = Format_PPT;
        [[THUFileManager defaultManager] setFile:self.fileName newExtension:@"ppt"];
    } 
    else if ([self.MIMEType isEqualToString:Format_PPT]) 
    {
        self.MIMEType = Format_XLS;
        [[THUFileManager defaultManager] setFile:self.fileName newExtension:@"xls"];
    } 
    else if ([self.MIMEType isEqualToString:Format_XLS]) 
    {
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"WebView did start loading data, type:%@", self.MIMEType);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"WebView did finish loading data, type:%@", self.MIMEType);
}

#pragma mark - UIAlertView Delegate

- (void)alertViewCancel:(UIAlertView *)alertView
{
    // Since the file is unable to be parsed, no content will be shown in this view.
    // So pop back to the last view controller automaticaly
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        // Re download the file data
    }
}

@end
