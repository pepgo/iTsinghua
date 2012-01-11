//
//  HomeworkListViewController.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THUViewController.h"

@interface HomeworkListViewController : THUViewController {
    NSArray *homeworkInfo;
    NSArray *homeworkState;
}

// @since 1.0.0
@property (strong, nonatomic) NSArray *homeworkInfo;
@property (strong, nonatomic) NSArray *homeworkState;

//@since 2011/12/8 support local notification of homework
@end
