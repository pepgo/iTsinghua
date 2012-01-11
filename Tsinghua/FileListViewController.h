//
//  FileListViewController.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THUViewController.h"
#import "DownloadManager.h"

// @since   1.0.3
@interface FileListViewController : THUViewController {
    NSArray *fileListArray;
    NSArray *fileSizeArray;
    NSArray *fileDescriptionArray;
    NSArray *fileUpdateTimeArray;
    NSArray *fileLinkURLArray;
    NSString *courseName;
}

@property (strong, nonatomic) NSString *courseName;

@end
