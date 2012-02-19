//
//  THUNetworkManager.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "THUNetworkManager.h"
#import "TFHpple.h"
#import "CourseInfo.h"
#import "QLoadingView.h"
#import "THUNotifications.h"

@interface THUNetworkManager ()

// Properties used to calculate the download rate
@property (strong, nonatomic) NSDate *timeFrom;
@property (strong, nonatomic) NSDate *timeNow;

@end



static NSString *loginBaseString = @"https://learn.tsinghua.edu.cn/MultiLanguage/lesson/teacher/loginteacher.jsp?userid=";
static NSString *courseInfoString = @"http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/MyCourse.jsp?language=cn";

@implementation THUNetworkManager

@synthesize cookies;
@synthesize lastRequestURL;
@synthesize lastRequestType;
@synthesize urlResponse;
@synthesize urlConnection;
@synthesize urlResponseData;
@synthesize expectedLength;
@synthesize delegate;
@synthesize timeFrom;
@synthesize timeNow;

+ (THUNetworkManager *)sharedManager {
    // See comment in header.
    static THUNetworkManager * sTHUNetworkManager;
    
    // This can be called on any thread, so we synchronise.  We only do this in 
    // the sTHUNetworkManager case because, once sTHUNetworkManager goes non-nil, it can 
    // never go nil again.
    
    if (sTHUNetworkManager == nil) {
        @synchronized (self) {
            sTHUNetworkManager = [[THUNetworkManager alloc] init];
            assert(sTHUNetworkManager != nil);
        }
    }
    
    return sTHUNetworkManager;
}

- (void)cancelCurrentRequest
{
    if (self.urlConnection != nil) 
    {
        [self.urlConnection cancel];
    }
}

- (void)sendNetworkRequest:(NSString *)requestType url:(NSString *)requestURL object:(NSArray *)object
{
    if ([requestType isEqual:thuLoginRequest]) {
        requestURL = [NSString stringWithFormat:@"%@%@%@%@", 
                      loginBaseString, 
                      [object objectAtIndex:kLoginNameIndex], 
                      @"&userpass=", 
                      [object objectAtIndex:kLoginPasswordIndex]];
    } 
    if (requestURL == nil) {
        requestURL = [NSString stringWithString:courseInfoString];
    }
    // Store the request url since the request is not the login request.
    self.lastRequestURL = requestURL;
    self.lastRequestType = requestType;
    
    // Send the asynchronous request
    NSURL *url;
    if ([self.lastRequestType isEqualToString:thuFileDownloadRequest]) {
        url = [NSURL URLWithString:requestURL];
    } else {
        url = [NSURL URLWithString:[requestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:60.0];
    if (![self.lastRequestType isEqualToString:thuLoginRequest]) {
        [urlRequest addValue:cookies forHTTPHeaderField:@"Cookie"];
    }
    self.urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

//the methods below send a login request to http://learn.tsinghua.edu.cn
//then send a notification to the main notification center for whether login successfully
- (void)parseLoginReturnData:(NSData *)buffer response:(NSURLResponse *)response
{
    NSString *string = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:string];
    //I use a scanner to replace the tags in the html with space
    //in order to check the content infomation of whether login successfully
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
        [theScanner scanUpToString:@">" intoString:&text] ;
        string = [string stringByReplacingOccurrencesOfString:
                  [ NSString stringWithFormat:@"%@>", text]
                                                   withString:@""];
    }    
    NSRange range = [string rangeOfString:@"alert"];
    NSNotification *notification = nil;
    if (range.location == 27) {
        //login failed
        //actually if login failed the html will include a 'alert' word in the location of 27
        notification = [NSNotification notificationWithName:thuLoginFailedNotification object:nil];
    } else {
        //login successfully
        notification = [NSNotification notificationWithName:thuLoginSucceedNotification object:nil];
        //then I set a cookie because I need a cookie to complete further request
        NSDictionary *fields = [(NSHTTPURLResponse *)response allHeaderFields];
        cookies = [fields valueForKey:@"Set-Cookie"];
    }
    //send the notification include login info to default notification center 
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

//login view controller use methods below 
//when it init to get basic info data ,each course`s link URL and course name from the first web page
- (void)getCourseInfoArray:(NSData *)courseInfo {
    NSMutableArray *courseNameArray = [[NSMutableArray alloc] init];
    NSMutableArray *countOfUnhandledHomeworks = [[NSMutableArray alloc] init];
    NSMutableArray *linkURLOfCourse = [[NSMutableArray alloc] init];

    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:courseInfo];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[2]/tr/td/a"];
    TFHppleElement *element = [elements objectAtIndex:0];
    NSUInteger length = [elements count];
    NSString *string;
    
    //get course name
    for (NSUInteger i = 0; i < length; i++) {
        element = (TFHppleElement *)[elements objectAtIndex:i];
        if ([element firstChild] != nil) {
            string = [[element firstChild] content];
        } else {
            string = [element content];
        }

        NSScanner *theScanner;
        NSString *text = nil;
        theScanner = [NSScanner scannerWithString:string];
        while ([theScanner isAtEnd] == NO) {
            [theScanner scanUpToString:@"(" intoString:NULL] ; 
            [theScanner scanUpToString:@")" intoString:&text] ;
            string = [string stringByReplacingOccurrencesOfString:
                      [ NSString stringWithFormat:@"%@)", text]
                                                       withString:@" "];
        }
        [courseNameArray insertObject:string atIndex:i];
    }
    [[CourseInfo sharedCourseInfo] setCourseName:courseNameArray];
    
    //get unhandled homeworks counts
    NSArray *elements_unhandled = [xpathParser searchWithXPathQuery:@"//table[2]/tr/td/span"];
    for (NSUInteger i = 0; i < length; i++) {
        element = (TFHppleElement *)[elements_unhandled objectAtIndex:i];
        string = [element content];
        [countOfUnhandledHomeworks insertObject:string atIndex:i];
    }
    [[CourseInfo sharedCourseInfo] setCountOfUnhandledHomeworks:countOfUnhandledHomeworks];
    
    //get each course`s link URL
    elements  = [xpathParser searchWithXPathQuery:@"//table[2]/tr/td/a"];
    element = [elements objectAtIndex:0];
    NSDictionary *attributes = [[NSDictionary alloc] init];
    length = [elements count];
    for (NSUInteger i = 0; i < length; i++) {
        element = (TFHppleElement *)[elements objectAtIndex:i];
        attributes = [element attributes];
        [linkURLOfCourse insertObject:[attributes objectForKey:@"href"] atIndex:i];
    }
    [[CourseInfo sharedCourseInfo] setCourseURL:linkURLOfCourse];
    
    NSNotification *endNotification = [NSNotification notificationWithName:@"end getting" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:endNotification];
}

//homework view use methods below when it need to init a homework list view
- (void)getHomeworkArray:(NSData *)homeworkData {
    NSMutableArray *homeworkArray = [[NSMutableArray alloc] init];
    NSMutableArray *homeworkState = [[NSMutableArray alloc] init];
    NSMutableArray *homeworkDetailURL = [[NSMutableArray alloc] init];
    NSMutableArray *homeworkDeadline = [[NSMutableArray alloc] init];

    //get homework array for selected course in the list
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:homeworkData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[2]/tr/td/a"];
    TFHppleElement *element;
    NSUInteger length = [elements count];
    for (NSUInteger i = 0; i < length; i++) {
        element = (TFHppleElement *)[elements objectAtIndex:i];
        [homeworkArray insertObject:[element content] atIndex:i];
    }
    
    //get homework state for each homework in the list
    elements  = [xpathParser searchWithXPathQuery:@"//table[2]/tr/td[4]"];
    length = [elements count];
    for (NSUInteger i = 0; i < length; i++) {
        element = (TFHppleElement *)[elements objectAtIndex:i];
        NSLog(@"%@", element.content);
        [homeworkState insertObject:[element content] atIndex:i];
    }
    
    //get link URL for each homework in the list
    elements  = [xpathParser searchWithXPathQuery:@"//table[2]/tr/td/a"];
    length = [elements count];
    NSDictionary *attributes = [[NSDictionary alloc] init];
    for (NSUInteger i = 0; i < length; i++) 
    {
        element = (TFHppleElement *)[elements objectAtIndex:i];
        attributes = [element attributes];
        [homeworkDetailURL insertObject:[attributes objectForKey:@"href"] atIndex:i];
    }
    
    //get deadline of each homework in the list
    elements  = [xpathParser searchWithXPathQuery:@"//table[2]/tr/td[3]"];
    length = [elements count];
    for (NSUInteger i = 0; i < length; i++) 
    {
        element = (TFHppleElement *)[elements objectAtIndex:i];
        [homeworkDeadline insertObject:[element content] atIndex:i];
    }

    [[CourseInfo sharedCourseInfo] setHomeworkDeadline:homeworkDeadline];
    [[CourseInfo sharedCourseInfo] setHomeworkDetailURL:homeworkDetailURL];
    [[CourseInfo sharedCourseInfo] setHomeworkInfo:homeworkArray];
    [[CourseInfo sharedCourseInfo] setHomeworkState:homeworkState];
}

//homework list view use methods below to init a homework detail view
- (void)getHomeworkDetailInfo:(NSData *)homeworkDetailData {
    NSString *homeworkDetailContent = [[NSString alloc] init];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:homeworkDetailData];
    
    //get content of the current homework
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[2]/td[2]/textarea"];
    homeworkDetailContent = (NSString *)[(TFHppleElement *)[elements objectAtIndex:0] content];
    [[CourseInfo sharedCourseInfo] setHomeworkDetailContent:homeworkDetailContent];
    
    //get detail head label of the current homework
    NSString *homeworkDetailHeader = [[NSString alloc] init];
    elements = [xpathParser searchWithXPathQuery:@"//table[1]/tr[1]/td[2]"];
    homeworkDetailHeader = (NSString *)[(TFHppleElement *)[elements objectAtIndex:0] content];
    [[CourseInfo sharedCourseInfo] setHomeworkDetailHead:homeworkDetailHeader];
    
}

//note view controller call the methods below 
//to get note basic info, note update time, note link URL
- (void)getNoteArray:(NSData *)noteData {
    NSMutableArray *noteArray = [[NSMutableArray alloc] init];
    NSMutableArray *noteURL = [[NSMutableArray alloc] init];
    NSMutableArray *noteDateArray = [[NSMutableArray alloc] init];

    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:noteData];
    
    //get note basic info
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr/td/a"];
    if ([elements count] != 0) {
        TFHppleElement *element;
        NSUInteger length = [elements count];
        // Access the first cell
        for (NSUInteger i = 0; i < length; i++) {
            element = (TFHppleElement *)[elements objectAtIndex:i];
            if ([element firstChild] != nil) {
                [noteArray insertObject:[element firstChild].content atIndex:i];
            } else {
            [noteArray insertObject:[element content] atIndex:i];
            }
        }
        [[CourseInfo sharedCourseInfo] setNoteBasicInfo:noteArray];
    }
    
    //get note update time
    TFHppleElement *element;
    elements = [xpathParser searchWithXPathQuery:@"//table[1]/tr/td[4]"];
    if ([elements count] != 0) {
        NSUInteger length = [elements count];
        for (NSUInteger i = 0; i < length; i++) {
            element = (TFHppleElement *)[elements objectAtIndex:i];
            [noteDateArray insertObject:[element content] atIndex:i];
        }
        [noteDateArray removeObjectAtIndex:0];
        [[CourseInfo sharedCourseInfo] setNoteUpDate:noteDateArray];
    }
    
    //get note link URL 
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr/td/a"];
    if ([elements count] != 0) {
        TFHppleElement *element;
        NSUInteger length = [elements count];
        NSDictionary *attributes = [[NSDictionary alloc] init];
        // Access the first cell
        for (NSUInteger i = 0; i < length; i++) {
            element = (TFHppleElement *)[elements objectAtIndex:i];
            attributes = [element attributes];
            [noteURL insertObject:[attributes objectForKey:@"href"] atIndex:i];
        }
        [[CourseInfo sharedCourseInfo] setNoteURL:noteURL];
    }
}

//since the content info is so complex 
//I decide to use a web view instead of using a local view and parse html of the web page
//and the methods won`t be used in current versions
- (void)getNoteContentInfo:(NSData *)noteContentDate {
    NSString *noteContent = [[NSString alloc] init];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:noteContentDate];
    
    //Get all the cells of the 2nd row of the 3rd table 
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[2]/td[2]"];
    noteContent = (NSString *)[(TFHppleElement *)[elements objectAtIndex:0] content];
    
    NSString *noteHead = [[NSString alloc] init];
    elements = [xpathParser searchWithXPathQuery:@"//table[0]/tr[1]/td[2]"];
    noteHead = (NSString *)[(TFHppleElement *)[elements objectAtIndex:0] content];
}

- (void)getFileListInfo:(NSData *)fileListDate {
    NSMutableArray *fileListArray = [[NSMutableArray alloc] init];
    NSMutableArray *fileDescriptionArray = [[NSMutableArray alloc] init];
    NSMutableArray *fileSizeArray = [[NSMutableArray alloc] init];
    NSMutableArray *fileUpdateTimeArray = [[NSMutableArray alloc] init];
    NSMutableArray *fileLinkURLArray = [[NSMutableArray alloc] init];
    
    //get file array for selected course in the list
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:fileListDate];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr/td/a"];
    TFHppleElement *element;
    NSUInteger serialNumber = 0;
    NSRange range;
    NSUInteger length = [elements count];
    for (NSUInteger i = 0; i < length; i++) {
        element = (TFHppleElement *)[elements objectAtIndex:i];
        range = [[element content] rangeOfString:@"序"];
       
        if (range.location == 0 && [element content] != NULL) {
            serialNumber += 1;
            if (serialNumber ==3) {
                break;
            }
        }
        if (i > 3) 
        {    
            if ([element firstChild].content != nil) {
                NSString *fileName = [[[element firstChild] content] stringByReplacingOccurrencesOfString:@" " withString:@" "];
                [fileListArray insertObject:fileName atIndex:i - 4];

            } else {
                NSString *fileName = [[element content] stringByReplacingOccurrencesOfString:@" " withString:@" "];
                [fileListArray insertObject:fileName atIndex:i - 4];
            }
        }
    }
    [[CourseInfo sharedCourseInfo] setFileListInfo:fileListArray];
    
    //get file description for selected course
    xpathParser = [[TFHpple alloc] initWithHTMLData:fileListDate];
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr/td"];
    length = [elements count];
    TFHppleElement *element2;
    TFHppleElement *element3;
    TFHppleElement *element4;
    serialNumber = 0;
    NSUInteger i = 0;
    while (i < length) {
        element = (TFHppleElement *)[elements objectAtIndex:i];
        range = [[element content] rangeOfString:@"文件大小"];
        //NSLog(@"location %d",range.location);
        if (range.location == 0 && [element content] != NULL) {
            //NSLog(@"%@",[element content]);
            i++;
            while (i < length - 1) {
                i++;
                //element is the number of the file
                element = (TFHppleElement *)[elements objectAtIndex:i++];
                //element2 is the description of file
                i++;
                element2 = (TFHppleElement *)[elements objectAtIndex:i++];
                if ([element2 content]) {
                    [fileDescriptionArray addObject:[element2 content]];
                } else {
                    [fileDescriptionArray addObject:@"No Description"];
                }
                //element3 is the size of the file
                element3 = (TFHppleElement *)[elements objectAtIndex:i++];
                if ([[element3 content] isEqualToString:@"文件大小"]) {
                    break;
                }
                [fileSizeArray addObject:[element3 content]];
                //element4 is the update time of file
                element4 = (TFHppleElement *)[elements objectAtIndex:i++];
                [fileUpdateTimeArray addObject:[[element4 content] stringByReplacingOccurrencesOfString:@"2011-" withString:@" "]];
                i--;
            }
            break;
        }
        i++;
    }
    
    elements  = [xpathParser searchWithXPathQuery:@"//table[1]/tr[position()>1]/td[2]/a"];
    length = [elements count];
    NSDictionary *attributes = [[NSDictionary alloc] init];
    for (NSUInteger i = 0; i < length; i++) {
        element = (TFHppleElement *)[elements objectAtIndex:i];
        attributes = [element attributes];
        [fileLinkURLArray insertObject:[attributes objectForKey:@"href"] atIndex:i];
    }

    [[CourseInfo sharedCourseInfo] setFileLinkURLInfo:fileLinkURLArray];
    [[CourseInfo sharedCourseInfo] setFileDescreitionInfo:fileDescriptionArray];
    [[CourseInfo sharedCourseInfo] setFileUpdateInfo:fileUpdateTimeArray];
    [[CourseInfo sharedCourseInfo] setFileSizeInfo:fileSizeArray];
}

#pragma mark - NSURL Connection Data Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.urlResponseData = [NSMutableData data];
    self.urlResponse = response;
    self.timeFrom = [NSDate date];
    
    //determine the file type
    NSLog(@"file type:%@",[response suggestedFilename]);
    if ([[response suggestedFilename] rangeOfString:@"."].location != NSNotFound) {
        NSMutableDictionary *fileTypeDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
        NSArray *tempArray = [[response suggestedFilename] componentsSeparatedByString:@"."];
        if ([[tempArray objectAtIndex:1] isEqual:@"pdf"]) {
            [fileTypeDictionary setObject:@"pdf" forKey:@"FILE_TYPE"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_FILE_TYPE" object:nil userInfo:fileTypeDictionary];
        } else if ([[tempArray objectAtIndex:1] isEqual:@"doc"] || [[tempArray objectAtIndex:1] isEqual:@"docx"]) {
            [fileTypeDictionary setObject:@"doc" forKey:@"FILE_TYPE"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_FILE_TYPE" object:nil userInfo:fileTypeDictionary];        
        } else if ([[tempArray objectAtIndex:1] isEqual:@"ppt"] || [[tempArray objectAtIndex:1] isEqual:@"pptx"]) {
            [fileTypeDictionary setObject:@"ppt" forKey:@"FILE_TYPE"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_FILE_TYPE" object:nil userInfo:fileTypeDictionary];      
        } else if ([[tempArray objectAtIndex:1] isEqual:@"xls"] || [[tempArray objectAtIndex:1] isEqual:@"xlsx"]) {
            [fileTypeDictionary setObject:@"xls" forKey:@"FILE_TYPE"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_FILE_TYPE" object:nil userInfo:fileTypeDictionary];   
        } else {
            //common html file that don`t need to be read or stored
            NSLog(@"the file is not a readable file");
        }
    }
    
    if ([lastRequestType isEqualToString:thuFileDownloadRequest]) {
        // Store the expected content length for showing the progress
        self.expectedLength = [NSNumber numberWithLongLong:response.expectedContentLength];
        
        // Notify the delegate that the download progress begins
        [delegate downloadConnectionDidStart:connection];
    }

#ifdef DEBUG
    // Inform the user
    NSLog(@"Connection Received\nRequest Type:%@\nRequest URL:%@", 
          self.lastRequestType, 
          self.lastRequestURL);
#endif
}

// Note:
// -connection:didReceiveData: will be called frequently, when receiving every new amount of data.
// As we have got the expected length of the data, we could show the download progress easily.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.timeNow = [NSDate date];
    [self.urlResponseData appendData:data];
    
    if ([lastRequestType isEqualToString:thuFileDownloadRequest]) 
    {
        float totalLength = self.expectedLength.floatValue;
        float finishedLength = (float)self.urlResponseData.length;
        [delegate downloadConnection:connection inProgress:finishedLength/totalLength];
        
        NSTimeInterval timePass = [self.timeNow timeIntervalSinceDate:self.timeFrom];
        [delegate downloadConnection:connection receiveDataRate:(float)data.length/8/1024/timePass];
    }
    
    self.timeFrom = self.timeNow;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
#ifdef DEBUG
    // Inform the user.
    NSLog(@"Download failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSLog(@"Connection Time Out\nRequest Type:%@\nRequest URL:%@", 
          self.lastRequestType, 
          self.lastRequestURL);
#endif
    // Post the time out notification 
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:thuTimeOutNotification object:nil]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self.lastRequestType isEqualToString:thuLoginRequest]) {
        [self parseLoginReturnData:self.urlResponseData response:self.urlResponse];
    }
    else if ([self.lastRequestType isEqualToString:thuCourseRequest]) {
        [self getCourseInfoArray:self.urlResponseData];
        [[CourseInfo sharedCourseInfo] setBasicCourseData:self.urlResponseData];
    } 
    else if ([self.lastRequestType isEqualToString:thuHomeworkRequest]) {
        [self getHomeworkArray:self.urlResponseData];
    } 
    else if ([self.lastRequestType isEqualToString:thuHomeworkDetailRequest]) {
        [self getHomeworkDetailInfo:self.urlResponseData];
    } 
    else if ([self.lastRequestType isEqualToString:thuFileListRequest]) {
        [self getFileListInfo:self.urlResponseData];
    } 
    else if ([self.lastRequestType isEqualToString:thuNoteRequest]) {
        [self getNoteArray:self.urlResponseData];
    }
    else if ([self.lastRequestType isEqualToString:thuNoteContentRequest]) {
        [self getNoteContentInfo:self.urlResponseData];
    }
    else if ([self.lastRequestType isEqualToString:thuFileDownloadRequest]) {
        [delegate downloadConnectionDidFinish:connection data:self.urlResponseData];
    }
    
    // Release the current connection and data
    self.urlConnection = nil;
    self.urlResponseData = nil;
    
    // Post the network request finish notification
    NSNotification *notification = [NSNotification notificationWithName:thuRequestFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

#ifdef DEBUG
    NSLog(@"Connection finished\nStatus:Succeed\nRequest Type:%@\nRequest URL:%@", 
          self.lastRequestType, 
          self.lastRequestURL);
#endif
}

@end