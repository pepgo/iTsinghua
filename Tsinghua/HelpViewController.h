//
//  HelpViewController.h
//  Tsinghua
//
//  Created by Xin Chen on 11-11-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController <UIScrollViewDelegate> {
    UIPageControl *pageController;
    UIScrollView *scrollView;
}

@property (retain, nonatomic) IBOutlet UIPageControl *pageController;

@end
