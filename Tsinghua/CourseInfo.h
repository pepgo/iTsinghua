//
//  CourseInfo.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

/*
 Change Log(@since 1.0.4):
 1. New Function - clearUpCourseInfo added. 
 2. Simplify the implementation for -(id)init. 
 */

#import <Foundation/Foundation.h>

@interface CourseInfo : NSObject 
{
    NSArray *courseName;
    NSArray *countOfUnhandledHomeworks;
    NSData *basicCourseData;
    NSArray *courseURL;
    NSArray *homeworkInfo;
    NSArray *homeworkState;
    NSArray *homeworkDetailURL;
    NSArray *homeworkDeadline;
    NSString *homeworkDetailContent;
    NSString *homeworkDetailHead;
    NSArray *noteURL;
    NSMutableArray *noteBasicInfo;
    NSArray *noteUpDate;
    NSMutableArray *fileListInfo;
    NSMutableArray *fileLinkURLInfo;
    NSMutableArray *fileSizeInfo;
    NSMutableArray *fileDescreitionInfo;
    NSMutableArray *fileUpdateInfo;
    NSMutableArray *notesCount;
}

@property (strong, nonatomic) NSArray *courseName;
@property (strong, nonatomic) NSArray *countOfUnhandledHomeworks;
@property (strong, nonatomic) NSData *basicCourseData;
@property (strong, nonatomic) NSArray *courseURL;
@property (strong, nonatomic) NSArray *homeworkInfo;
@property (strong, nonatomic) NSArray *homeworkState;
@property (strong, nonatomic) NSArray *homeworkDetailURL;
@property (strong, nonatomic) NSArray *homeworkDeadline;
@property (strong, nonatomic) NSString *homeworkDetailContent;
@property (strong, nonatomic) NSString *homeworkDetailHead;
@property (strong, nonatomic) NSArray *noteURL;
@property (strong, nonatomic) NSMutableArray *noteBasicInfo;
@property (strong, nonatomic) NSArray *noteUpDate;
@property (strong, nonatomic) NSMutableArray *fileListInfo;
@property (strong, nonatomic) NSMutableArray *fileSizeInfo;
@property (strong, nonatomic) NSMutableArray *fileDescreitionInfo;
@property (strong, nonatomic) NSMutableArray *fileUpdateInfo;
@property (strong, nonatomic) NSMutableArray *fileLinkURLInfo;
@property (strong, nonatomic) NSMutableArray *notesCount;
@property (strong, nonatomic) NSMutableArray *fileCount;

// @since 1.0.0
+ (CourseInfo *)sharedCourseInfo;

// Function:
// Clear up all the stored course info. Called after the user pressing logout button
// @since 1.0.4
- (void)clearUpCourseInfo;

@end
