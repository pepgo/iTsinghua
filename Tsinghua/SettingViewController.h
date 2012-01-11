//
//  AboutViewController.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "THUViewController.h"

// @since 2011/12/8
// 
// We set up this new tab providing the user to delete userinfo in user default and delete files that they downloaded.
// We also provide a way to contact or report to us using email and since today the application will support iPad and 
// is ready to push to the iTunes App Store.

@interface SettingViewController : THUViewController <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate,UIAlertViewDelegate> {
    UIScrollView *scrollView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)sendMailToFreeDev:(id)sender;
- (IBAction)deleteAllFiles:(id)sender;
- (IBAction)deleteUserInfo:(id)sender;
- (IBAction)showUs:(id)sender;

@end
