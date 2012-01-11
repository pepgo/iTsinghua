//
//  HomeworkViewController.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THUViewController.h"

@interface HomeworkViewController : THUViewController {
    NSArray *countOfUnhandledHomeworks;
}

// @since 1.0.0
@property (strong, nonatomic) NSArray *countOfUnhandledHomeworks;

@end
