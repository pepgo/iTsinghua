//
//  LoginViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "NetworkManager.h"
#import "AppDelegate.h"
#import "QLoadingView.h"
#define PI 3.1415

@implementation LoginViewController

@synthesize userName = _userName;
@synthesize userPasswords = _userPasswords;
@synthesize imageView;
@synthesize pageController;
@synthesize loginButton;

#pragma mark - View lifecycle


// Function: Smooth animation for moving down the view.
- (void)textFieldDidEndEditing 
{
    [UIView beginAnimations:@"UIViewMoveDown" context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //self.view.center = CGPointMake(384, 512);
    } else {
        self.view.center = CGPointMake(160.0f, 240.0f);
    }
    
    [self.userName endEditing:YES];
    [self.userPasswords endEditing:YES];
    [UIView commitAnimations];
}

// Function: Smooth animation for moving up the view.
- (void)textFieldDidStartEditing 
{
    [UIView beginAnimations:@"UIViewMoveDown" context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //self.view.center = CGPointMake(384, 512);
    } else {
        self.view.center = CGPointMake(160.0f, 180.0f);
    }
    
    [UIView commitAnimations];
}

- (void)loginSucceed:(NSNotification *)notification
{
    NSAssert([notification.name isEqualToString:thuLoginSucceedNotification], @"");
    
    // Perform the view transition from the login view to the main view
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate performViewTransitionIn:YES];
    
    // Save the account name and password
    [self saveUserAccount];
    
    // Hide the loading view in HomeworkViewController
}

- (void)loginFailed:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" 
                                                    message:@"用户名或密码错误" 
                                                   delegate:nil 
                                          cancelButtonTitle:@"好的，重新尝试" 
                                          otherButtonTitles:nil, nil];
    [alert show];
    
    // Hide the loading view
    [QLoadingView hideWithAnimated:YES];
}

#pragma mark - page turn methods

- (void)pageTurn:(UIPageControl *)pageContol 
{
    int whichPage = pageContol.currentPage;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        scrollView.contentOffset = CGPointMake(768.0f * whichPage, 0.0f);
    } else {
        scrollView.contentOffset = CGPointMake(320.0f * whichPage, 0.0f);
    }
    
    [UIView commitAnimations];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    int currentPageNumber;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        currentPageNumber = offset.x / 768.0f;
    } else {
        currentPageNumber = offset.x / 320.0f;
    }
    if (currentPageNumber == 3) {
        CATransition *transition = [CATransition animation];
        transition.duration = 3.75f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        transition.type = kCATransitionFade;
        transition.delegate = self;
        [[UIApplication sharedApplication].keyWindow.layer addAnimation:transition forKey:nil];
        [scrollView removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow.layer removeAllAnimations];
    }
}


- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceed:) name:thuLoginSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed:) name:thuLoginFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endHelp) name:@"End Help" object:nil];
    
    [_userName addTarget:self action:@selector(textFieldDidEndEditing) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_userName addTarget:self action:@selector(textFieldDidStartEditing) forControlEvents:UIControlEventEditingDidBegin];
    [_userPasswords addTarget:self action:@selector(textFieldDidEndEditing) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_userPasswords addTarget:self action:@selector(textFieldDidStartEditing) forControlEvents:UIControlEventEditingDidBegin];
    [imageView setImage:[UIImage imageNamed:@"Tsinghua.jpg"]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipadlogin_bg2_iPad.png"]];
        } else {
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipadlogin_bg1_iPad.png"]];
        }
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bg.png"]];
    }

    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasShownHelpView"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasShownHelpView"];
        
        pageController.hidden = YES;
        [pageController removeFromSuperview];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 768.0f, 1024.0f)];
            
            scrollView.contentSize = CGSizeMake(4 * 768.f, scrollView.frame.size.height);
        } else {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
            
            scrollView.contentSize = CGSizeMake(4 * 320.f, scrollView.frame.size.height);
        }
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        
        for (int i = 1; i < 5; i ++) {
            NSString *imageName = [NSString stringWithFormat:@"slide%i.png",i];
            UIImageView *slideImageView = [[UIImageView alloc] init];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
               slideImageView.frame = CGRectMake((i - 1) * 768.0f, 0.0f, 768.0f, 1024.0f);
                
            } else {
               slideImageView.frame = CGRectMake((i - 1) * 320.0f, 0.0f, 320.0f, 480.0f);
            }
            slideImageView.image = [UIImage imageNamed:imageName];
            [scrollView addSubview:slideImageView];
        }
    
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.view addSubview:scrollView];
        }    
    
        pageController.numberOfPages = 5;
        pageController.currentPage = 0;
        [pageController addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    }
    
    [super viewDidLoad];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [[NSBundle mainBundle] loadNibNamed:@"LoginViewController_iPad" owner:self options:nil];
        if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            self.view.transform = CGAffineTransformMakeRotation(PI);
        }
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipadlogin_bg2_iPad.png"]];
    } else if (UIInterfaceOrientationIsLandscape(orientation)){
        [[NSBundle mainBundle] loadNibNamed:@"LoginViewController_iPad_land" owner:self options:nil];
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            self.view.transform = CGAffineTransformMakeRotation(PI + PI/2);
        } else {
            self.view.transform = CGAffineTransformMakeRotation(PI/2);
        }
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipadlogin_bg1_iPad.png"]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self textFieldDidEndEditing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadUserAccount];
    [super viewWillAppear:animated];
}

#pragma mark - Public Functions

- (IBAction)loginButtonPressed:(id)sender 
{
    if (![self.userName.text isEqual:@""] && ![self.userPasswords.text isEqual:@""]) 
    {
        [QLoadingView showWithInfo:@"正在验证用户名和密码..."];
        NSArray *requestParameters = [NSArray arrayWithObjects:self.userName.text, self.userPasswords.text, nil];
        [[NetworkManager sharedManager] sendNetworkRequest:thuLoginRequest url:nil object:requestParameters];
    }
}

- (void)saveUserAccount
{
    [[NSUserDefaults standardUserDefaults] setValue:self.userName.text forKey:@"current_account"];
    [[NSUserDefaults standardUserDefaults] setValue:self.userPasswords.text forKey:@"password"];
    NSLog(@"User account saved");
}

- (void)loadUserAccount
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"current_account"]) {
        // If the user name has been cached, the user password must be cached too since the saving process
        // exercuted only when login process succeeeds.
        self.userName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"current_account"];
        self.userPasswords.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
        NSLog(@"User account loaded");
    }
}

@end
