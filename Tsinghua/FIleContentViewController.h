//
//  FIleContentViewController.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THUViewController.h"
#import "DownloadManager.h"

// @since 1.0.4
static NSString *format_pdf = @"application/pdf";
static NSString *format_doc = @"application/msword";
static NSString *format_ppt = @"application/vnd.ms-powerpoint/";
static NSString *format_xls = @"application/vnd.ms-excel";
static NSString *textEncoding = @"utf-8";

@interface FIleContentViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate> {
    UIWebView *fileContentView;
    NSString *courseName;
    NSString *fileName;
    NSString *MIMEType;
    NSInteger index;
    NSData *documentData;
}

@property (strong, nonatomic) IBOutlet UIWebView *fileContentView;
@property (strong, nonatomic) NSString *MIMEType;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *courseName;
@property (strong, nonatomic) NSData *documentData;
@property (assign, nonatomic) NSInteger index;

// Initializer:
// @since 1.0.4
- (id)initWithCourseName:(NSString *)courseName fileName:(NSString *)fileName index:(NSInteger)index;

// Function:
// type:MIMEType for the file.
// 
// The webview will begin loading data using method loadData:MIMEType:textEncodingName:baseURL:.
// If the MIMEType is not right, this method will be re-called in webView:didFailedWithError and change
// the MIMEType. If all the four types tested but still can not be open, the data is unable to 
// load due to unknown formats.
// @since 1.0.4
- (void)webViewWillStartLoadingWithType:(NSString *)type;

@end
