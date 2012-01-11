//
//  NoteDetailViewController.h
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteDetailViewController : UIViewController <UIWebViewDelegate> {
    UIWebView *noteWebView;
    NSString *urlString;
}

@property (strong, nonatomic) IBOutlet UIWebView *noteWebView;
@property (strong, nonatomic) NSString *urlString;

- (id)initWithURLString:(NSString *)url;

@end
