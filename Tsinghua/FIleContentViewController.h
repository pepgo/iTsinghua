//
//  FIleContentViewController.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THUViewController.h"
#import "THUDownloadManager.h"

// @since 1.4
static NSString *Format_PDF = @"application/pdf";
static NSString *Format_DOC = @"application/msword";
static NSString *Format_PPT = @"application/vnd.ms-powerpoint";
static NSString *Format_XLS = @"application/vnd.ms-excel";
static NSString *textEncoding = @"utf-8";

// @since 2.2
static NSString *PDFHeaderString = @"<25504446>";

@interface FileContentViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate> 
{
    UIWebView *fileContentView;
    UISlider  *downloadSlider;
    UILabel   *waitingLabel;
    UILabel   *downloadRateLabel;
    NSString  *courseName;
    NSString  *fileName;
    NSString  *fileType;
    NSString  *MIMEType;
    NSInteger  index;
    NSData    *documentData;
    BOOL       fileExist;
}

@property (strong, nonatomic) IBOutlet UIWebView *fileContentView;
@property (strong, nonatomic) IBOutlet UISlider *downloadSlider;
@property (strong, nonatomic) IBOutlet UILabel *waitingLabel;
@property (strong, nonatomic) IBOutlet UILabel *downloadRateLabel;
@property (strong, nonatomic) NSString *MIMEType;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *fileType;
@property (strong, nonatomic) NSString *courseName;
@property (strong, nonatomic) NSData *documentData;
@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) BOOL fileExist;

// Initializer:
// @since 1.4
- (id)initWithCourseName:(NSString *)courseName fileName:(NSString *)fileName fileType:(NSString *)type index:(NSInteger)index exist:(BOOL)exist;

// Function:
// type:MIMEType for the file.
// 
// The webview will begin loading data using method loadData:MIMEType:textEncodingName:baseURL:.
// If the MIMEType is not right, this method will be re-called in webView:didFailedWithError and change
// the MIMEType. If all the four types tested but still can not be open, the data is unable to 
// load due to unknown formats.
// @since 1.4
- (void)webViewWillStartLoadingWithType:(NSString *)type;

// Function:
// Called when download progress notification received. This will change the slider value
// @since 2.0
- (void)downloadProgressDidChange:(NSNotification *)notification;

// Function:
// Called when view will pop back to last view controller. This will stop any unstopped network connection.
// @since 2.0
- (void)viewWillPop;

@end
