//
//  NoteDetailViewController.m
//  Tsinghua
//
//  Created by 张 初阳 on 11-10-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NoteDetailViewController.h"
#import "THUNetworkManager.h"

@implementation NoteDetailViewController

@synthesize noteWebView;
@synthesize urlString;

- (id)initWithURLString:(NSString *)url
{
    if (self = [super init]) {
        self.urlString = url;
    }
    return self;
}

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
    
    // Create and load the url request
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *urlRequst = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                         timeoutInterval:100];
    [urlRequst addValue:[[THUNetworkManager sharedManager] cookies] forHTTPHeaderField:@"Cookie"];
    [self.noteWebView loadRequest:urlRequst];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // Inform user the error
    NSLog(@"Error: %@", error.localizedDescription);
}

@end
