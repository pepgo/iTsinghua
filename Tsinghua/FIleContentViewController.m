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

#pragma mark - get notification of file type to determine the MIME type
- (void)determineFileType:(NSNotification *)notification 
{
    self.fileType = [[notification userInfo] objectForKey:@"FILE_TYPE"];
    NSLog(@"type: %@ and file name:%@", self.fileType,self.fileName);
        
    if ([self.fileType isEqualToString:@"pdf"]) {
        self.MIMEType = Format_PDF;
        [[THUFileManager defaultManager] setFile:self.fileName newExtension:@"pdf"];
    } 
    else if ([self.fileType isEqual:@"doc"]) {
        self.MIMEType = Format_DOC;
        [[THUFileManager defaultManager] setFile:self.fileName newExtension:@"doc"];
    } 
    else if ([self.fileType isEqual:@"ppt"]) {
        self.MIMEType = Format_PPT;
        [[THUFileManager defaultManager] setFile:self.fileName newExtension:@"ppt"];
    } 
    else if ([self.fileType isEqual:@"xls"]) {
        self.MIMEType = Format_XLS;
        [[THUFileManager defaultManager] setFile:self.fileName newExtension:@"xls"];
    }
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    if (self.fileExist == YES) 
    {
        NSError *error = nil;
        NSString *fileFullName = [self.fileName stringByAppendingPathExtension:self.fileType];
        self.documentData = [[THUFileManager defaultManager] loadDataForFileName:fileFullName course:self.courseName error:&error];
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
        [[THUDownloadManager sharedManager] startDownload:[self.fileName stringByAppendingPathExtension:@"pdf"] 
                                                forCourse:self.courseName withUrl:url];
        
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
    //NSAssert(self.documentData != nil, @"The data file is nil or corrupted!");

    NSString *fileFullName = [self.fileName stringByAppendingPathExtension:self.fileType];
    NSString *fileFullPath = [[THUFileManager defaultManager] directoryForFile:fileFullName course:self.courseName];
    
    NSArray *fileTypeArray = [fileFullName componentsSeparatedByString:@"."];
    NSString *realFileType = [fileTypeArray objectAtIndex:1];
    if ([realFileType isEqualToString:@"pdf"]) {
        type = Format_PDF;
    } else if ([realFileType isEqualToString:@"doc"] || [realFileType isEqualToString:@"docx"]) {
        type = Format_DOC;
    } else if ([realFileType isEqualToString:@"ppt"] || [realFileType isEqualToString:@"pptx"]) {
        type = Format_PPT;
    } else if ([realFileType isEqualToString:@"xls"] || [realFileType isEqualToString:@"xlsx"]) {
        type = Format_XLS;
    } 
    
    NSLog(@"@file name:%@",fileFullName);
    NSLog(@"file path:%@",fileFullPath);
    NSLog(@"file type:%@",type);
    
    NSURLRequest *loadRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:fileFullPath]];
    [self.fileContentView loadRequest:loadRequest];


    NSData *fileSubData = [self.documentData subdataWithRange:NSMakeRange(0, 4)];
    NSString *dataHeaderString = [fileSubData description];
    if ([dataHeaderString isEqualToString:PDFHeaderString]) 
    {
        // Load the PDF file directly
        [self.fileContentView loadData:self.documentData MIMEType:type textEncodingName:textEncoding baseURL:nil];
    }
    else
    {
        
        [[THUFileManager defaultManager] setFile:self.fileName newExtension:@"doc"];
        [self.fileContentView loadData:self.documentData MIMEType:type textEncodingName:textEncoding baseURL:nil];
         
    }
    
}

- (void)downloadDidFinish:(NSNotification *)notification
{
    if ([notification.name isEqualToString:thuDownloadFinishNotification]) 
    {
        NSError *error = nil;
        NSString *fileFullName = [self.fileName stringByAppendingPathExtension:self.fileType];
        self.documentData = [[THUFileManager defaultManager] loadDataForFileName:fileFullName course:self.courseName error:&error];
        NSLog(@"file full name:%@",fileFullName);
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
        NSLog(@"MIME type:%@",self.MIMEType);
        
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(determineFileType:) name:@"GET_FILE_TYPE" object:nil];
    
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
    /*if ([self.MIMEType isEqualToString:Format_DOC]) 
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
    
    [self webViewWillStartLoadingWithType:self.MIMEType];*/
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
