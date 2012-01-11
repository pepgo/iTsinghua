//
//  HelpViewController.m
//  Tsinghua
//
//  Created by Xin Chen on 11-11-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"

@implementation HelpViewController

@synthesize pageController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - page turn methods
- (void)pageTurn:(UIPageControl *)pageContol {
    int whichPage = pageContol.currentPage;
    NSLog(@"page turned");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    scrollView.contentOffset = CGPointMake(320.0f * whichPage, 0.0f);
    
    [UIView commitAnimations];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    pageController.currentPage = offset.x / 320.0f;
    NSLog(@"%i",pageController.currentPage);
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
    scrollView.contentSize = CGSizeMake(3 * 320.f, scrollView.frame.size.height);
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    
    for (int i = 0; i < 4; i ++) {
        NSString *string = [NSString stringWithString:@"hello world"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * 320.0f, 0.0f, 320.0f, 37)];
        label.backgroundColor = [UIColor lightGrayColor];
        label.text = string;
        [scrollView addSubview:label];
    }
    
    [self.view addSubview:scrollView];
    
    pageController.numberOfPages = 4;
    pageController.currentPage = 0;
    [pageController addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
