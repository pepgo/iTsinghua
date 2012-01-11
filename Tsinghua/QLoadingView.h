//
//  QLoadingView.h
//  QWeiboSDK4iOSDemo
//
//  Created   on 11-1-18.
//   
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface QLoadingView : UIView 
{
	UIView *backgroundView;
	UIImageView *imageView;
	UILabel *labelInfo;
	UIImageView *boardView;
	UIActivityIndicatorView *activityView;
}

- (void)autoHide;
- (void)setImage:(UIImage *)image;
- (void)setModelInView:(BOOL)value;
- (void)setInfo:(NSString *)info;

+ (id)shareInstance;
+ (void)showWithImage:(UIImage *)image info:(NSString *)info;
+ (void)showWithInfo:(NSString *)info;
+ (void)hideWithAnimated:(BOOL)animated;

@end
