//
//  LoginViewController.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UIScrollViewDelegate> {
    UITextField *_userName;
    UITextField *_userPasswords;
    UIImageView *imageView;
    UIScrollView *scrollView;
    UIPageControl *pageController;
    UIButton *loginButton;
}

@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *userPasswords;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageController;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)loginButtonPressed:(id)sender;
- (void)loadUserAccount;
- (void)saveUserAccount;

@end
