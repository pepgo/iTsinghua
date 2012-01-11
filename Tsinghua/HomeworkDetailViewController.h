//
//  HomeworkDetailViewController.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THUViewController.h"

@interface HomeworkDetailViewController : THUViewController {
    UILabel *header;
    UITextView *content;
    UILabel *deadline;
    NSString *deadlineString;
    NSString *headString;
    NSString *contentString;
    UIButton *clockButton;
    
    int notisCount;
}

// @since 1.0.0
@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UITextView *content;
@property (strong, nonatomic) IBOutlet UILabel *deadline;
@property (strong, nonatomic) NSString *deadlineString;
@property (strong, nonatomic) IBOutlet UIButton *clockButton;

- (IBAction)notisCurrentHomework:(id)sender;

@end
