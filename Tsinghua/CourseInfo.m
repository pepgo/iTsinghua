//
//  CourseInfo.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CourseInfo.h"

@implementation CourseInfo

@synthesize courseName;
@synthesize countOfUnhandledHomeworks;
@synthesize basicCourseData;
@synthesize courseURL;
@synthesize homeworkInfo;
@synthesize homeworkState;
@synthesize homeworkDetailURL;
@synthesize homeworkDeadline;
@synthesize homeworkDetailContent;
@synthesize homeworkDetailHead;
@synthesize noteURL;
@synthesize noteBasicInfo;
@synthesize noteUpDate;
@synthesize fileListInfo;
@synthesize fileSizeInfo;
@synthesize fileUpdateInfo;
@synthesize fileDescreitionInfo;
@synthesize fileLinkURLInfo;

- (id)init 
{
    if (self = [super init]) 
    {
        self.noteBasicInfo = [[NSMutableArray alloc] init];
        self.fileListInfo = [[NSMutableArray alloc] init];
        self.fileDescreitionInfo = [[NSMutableArray alloc] init];
        self.fileSizeInfo = [[NSMutableArray alloc] init];
        self.fileUpdateInfo = [[NSMutableArray alloc] init];
        self.fileLinkURLInfo = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (CourseInfo *)sharedCourseInfo {
    static CourseInfo *sCourseinfo;
    if (sCourseinfo == nil) {
        @synchronized (self) {
            sCourseinfo = [[CourseInfo alloc] init];
            assert(sCourseinfo != nil);
        }
    }
    
    return sCourseinfo;
}

- (void)clearUpCourseInfo
{
    self.courseName = nil;
    self.countOfUnhandledHomeworks = nil;
    self.basicCourseData = nil;
    self.courseURL = nil;
    self.homeworkInfo = nil;
    self.homeworkState = nil;
    self.homeworkDetailURL = nil;
    self.homeworkDeadline = nil;
    self.homeworkDetailContent = nil;
    self.homeworkDetailHead = nil;
    self.noteURL = nil;
    self.noteBasicInfo = nil;
    self.noteUpDate = nil;
    self.fileListInfo = nil;
    self.fileDescreitionInfo = nil;
    self.fileSizeInfo = nil;
    self.fileUpdateInfo = nil;
    self.fileLinkURLInfo = nil;
    
    NSLog(@"Clear up all the previous course info.");
}

@end
