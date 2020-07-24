//
//  HSAboutViewController.m
//  PortGo
//
//  Created by MrLee on 14-9-25.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSRegisterViewController.h"
#import "UIBarButtonItem+HSBackItem.h"
#import <WebKit/WebKit.h>

@interface HSRegisterViewController ()
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property WKWebView* webView;

@end

@implementation HSRegisterViewController
@synthesize webPageURL;
@synthesize webPageTitle;

- (void)viewDidLoad {
    [super viewDidLoad];

    [_topView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbar_background.png"]]];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(onBack:)];

    self.webView =[[WKWebView alloc] init];
    self.webView.frame = CGRectMake(0, 0, ScreenWid, ScreenHeight-64);
    _webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
}

- (void) viewWillAppear:(BOOL)animated{
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:webPageURL]];
    self.titleLabel.text = webPageTitle;
    self.title = webPageTitle;
    [_webView loadRequest:request];
}

- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)returnButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
