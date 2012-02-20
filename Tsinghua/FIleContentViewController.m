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
@synthesize fileType;
@synthesize index;
@synthesize fileExist;

- (id)initWithCourseName:(NSString *)course fileName:(NSString *)file fileType:(NSString *)type index:(NSInteger)sIndex exist:(BOOL)exist 
{
    if (self = [super init]) 
    {
        self.courseName = course;
        self.fileName = file;
        self.index = sIndex;
        self.fileExist = exist;
        self.fileType = type;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Get the downloaded file type

- (void)determineFileType:(NSNotification *)notification 
{
    self.fileType = [[notification userInfo] objectForKey:@"fileExtension"];
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    if (self.fileExist == YES) 
    {
        // Load the file directly
        [self webViewStartLoadingFile];
        
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

- (void)webViewStartLoadingFile
{
    if (self.fileType == nil) 
    {
        self.fileType = [THUDownloadManager sharedManager].lastFileExtension;
    }
    NSString *fileFullName = [self.fileName stringByAppendingPathExtension:self.fileType];
    NSString *fileFullPath = [[THUFileManager defaultManager] directoryForFile:fileFullName course:self.courseName];
    NSURLRequest *loadRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:fileFullPath]];
    [self.fileContentView loadRequest:loadRequest];
}

- (void)downloadDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqualToString:thuDownloadFinishNotification]) 
    {
        // Start loading the file
        [self webViewStartLoadingFile];
        
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
    // Observe the file type notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(determineFileType:) 
                                                 name:thuFileExtensionNotification object:nil];
    
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
#ifdef DEBUG
    
    NSLog(@"FileContentViewController: error reading file : %@.%@. Error : %@", self.fileName, self.fileType, error.userInfo);
    
#endif
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"WebView did start loading file : %@.%@", self.fileName, self.fileType);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"WebView did finish loading file : %@.%@", self.fileName, self.fileType);
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
