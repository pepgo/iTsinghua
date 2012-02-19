//
//  AboutViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "CourseInfo.h"
#import "AboutUsViewController.h"
#import "THUFileManager.h"

@implementation SettingViewController

@synthesize scrollView;

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError *)error 
{    
    if (result == MFMailComposeResultFailed) {
        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"邮件发送失败" 
                                                               message:@"请检查您的网络连接" 
                                                              delegate:nil 
                                                     cancelButtonTitle:@"知道了" 
                                                     otherButtonTitles:nil, nil];
        [failureAlert show];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)sendMailToFreeDev:(id)sender 
{
    if ([MFMailComposeViewController canSendMail]) 
    {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setToRecipients:[NSArray arrayWithObjects:@"pepgozcy@gmail.com", @"Bismarrck@me.com", nil]];
        [mailViewController setSubject:@"I have somting about the app to tell you:)"];
        
        // Self should be set to the delegate of the mailComposeDelegate.
        // The delegate property of the mailViewController refes to the NavigationControllerDelegate
        mailViewController.mailComposeDelegate = self;
        
        [self.navigationController presentModalViewController:mailViewController animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == alertView.firstOtherButtonIndex) 
    {
        [[THUFileManager defaultManager] deleteAllFolders];
    }
}

- (IBAction)deleteAllFiles:(id)sender 
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您将删除所有已下载课件，是否继续？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
    [alertView show];
}

- (IBAction)deleteUserInfo:(id)sender 
{
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"current_account"];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"password"];
    NSLog(@"User account saved");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的登陆信息已经清除:)" message:nil delegate:nil cancelButtonTitle:@"好的，谢谢～" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)showUs:(id)sender {
    AboutUsViewController *controller;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            controller = [[AboutUsViewController alloc] initWithNibName:@"AboutUsViewController_iPad" bundle:nil];
        } else {
            controller = [[AboutUsViewController alloc] initWithNibName:@"AboutUsViewController_iPad_land" bundle:nil];
        }
    } else {
        controller = [[AboutUsViewController alloc] initWithNibName:@"AboutUsViewController_iPhone" bundle:nil];
    }
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:controller animated:YES];
}

#pragma mark - 
#pragma mark init methods

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)]
    }
}*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"more2_iPad.png"]];
        } else {
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"more1_iPad.png"]];
        }
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"more.png"]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            [[NSBundle mainBundle] loadNibNamed:@"SettingViewController_iPad" owner:self options:nil];
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"more2_iPad.png"]];
        } else if (UIInterfaceOrientationIsLandscape(orientation)){
            [[NSBundle mainBundle] loadNibNamed:@"SettingViewController_iPad_land" owner:self options:nil];
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"more1_iPad.png"]];
        }
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            [[NSBundle mainBundle] loadNibNamed:@"SettingViewController_iPad" owner:self options:nil];
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"more2_iPad.png"]];
        } else if (UIInterfaceOrientationIsLandscape(orientation)){
            [[NSBundle mainBundle] loadNibNamed:@"SettingViewController_iPad_land" owner:self options:nil];
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"more1_iPad.png"]];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return NO;
    }
}

@end
