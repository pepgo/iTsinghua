//
//  THUNetworkManager.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

/*
 NSURLConnection provides support for downloading the contents of an NSURLRequest in a synchronous manner using the class method sendSynchronousRequest:returningResponse:error:. Using this method is not recommended, because it has severe limitations:
 1. The client application blocks until the data has been completely received, an error is encountered, or the request times out.
 2. Minimal support is provided for requests that require authentication.
 3. There is no means of modifying the default behavior of response caching or accepting server redirects.
 */


/*
 Change Log(@1.0.3):
 1. As the synchronous type of NSURLRequest is not supported by Apple, I use NSURLConnection to handle the network request.
 2. The former methods such as sendCourseRequest, sendHomeworkRequest:, etc have almost the same structure, so I combine all the
    request methods to sendNetworkRequest:url:object:.
 */


/*
 Change Log(@1.0.4):
 1. New request type - thuFileDownloadRequest. This request is called by the FileContentViewController to download the file.
 2. New Protocol - THUNetworkManagerDownloadDelegate. 
 3. New Notification - thuLoginSucceedNotification & thuLoginFailedNotification to replace the old 'LoginCheck'.
 */


/*
 Error Report:
 1. File name parsing error: if the file name on the web is red, THUNetworkManager could not parse it.
 */

#import <Foundation/Foundation.h>

#define kLoginNameIndex             0
#define kLoginPasswordIndex         1


// Request Type
// @since 1.3
static NSString *thuLoginName = @"thuLoginName";
static NSString *thuPassword = @"thuPassword";
static NSString *thuLoginRequest = @"thuLoginRequest";
static NSString *thuCourseRequest = @"thuCourseRequest";
static NSString *thuHomeworkRequest = @"thuHomeworkRequest";
static NSString *thuHomeworkDetailRequest = @"thuHomeworkDetailRequest";
static NSString *thuNoteRequest = @"thuNoteRequest";
static NSString *thuNoteContentRequest = @"thuNoteContentRequest";
static NSString *thuFileListRequest = @"thuFileListRequest";
// @since 1.4
static NSString *thuFileDownloadRequest = @"thuFileDownloadRequest";


@protocol THUNetworkManagerDownloadDelegate;

@interface THUNetworkManager : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSString *cookies;
    NSString *lastRequestURL;
    NSString *lastRequestType;
    NSURLConnection *urlConnection;
    NSURLResponse *urlResponse;
    NSMutableData *urlResponseData;
    NSNumber *expectedLength;
    id <THUNetworkManagerDownloadDelegate> delegate;
}

// @since 1.0
@property (strong, nonatomic) NSString *cookies;
@property (strong, nonatomic) NSString *lastRequestURL;
@property (strong, nonatomic) NSString *lastRequestType;
// @since 1.3
@property (strong, nonatomic) NSURLConnection *urlConnection;
@property (strong, nonatomic) NSURLResponse *urlResponse;
@property (strong, nonatomic) NSMutableData *urlResponseData;
@property (strong, nonatomic) NSNumber *expectedLength;
// @since 1.4
@property (strong, nonatomic) id <THUNetworkManagerDownloadDelegate> delegate;

// @since 1.0
+ (THUNetworkManager *)sharedManager;

// requestName: the type of the request. Available names are the static NSStrings above.
// requestURL:  the unescaped url string.
// object:      the parameters(name and password) for the login request.
// @since 1.2
- (void)sendNetworkRequest:(NSString *)requestName url:(NSString *)requestURL object:(NSArray *)object;

// Cancel current network connection if exists.
// @since 2.1
- (void)cancelCurrentRequest;

@end


// @since 1.4
@protocol THUNetworkManagerDownloadDelegate <NSObject>
- (void)downloadConnection:(NSURLConnection *)connection inProgress:(float)percentage;
- (void)downloadConnectionDidStart:(NSURLConnection *)connection;
- (void)downloadConnectionDidFinish:(NSURLConnection *)connection data:(NSData *)data;
- (void)downloadConnection:(NSURLConnection *)connection receiveDataRate:(float)downloadRate;
- (void)downloadConnection:(NSURLConnection *)connection fileExtension:(NSString *)extension;
@end

