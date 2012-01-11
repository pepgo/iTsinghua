//
//  NoteListViewController.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THUViewController.h"

@interface NoteListViewController : THUViewController {
    NSArray *basicNoteInfo;
    NSArray *noteTimeArray;
    NSArray *noteURLArray;
}

@property (strong, nonatomic) NSArray *basicNoteInfo;
@property (strong, nonatomic) NSArray *noteTimeArray;
@property (strong, nonatomic) NSArray *noteURLArray;

@end
