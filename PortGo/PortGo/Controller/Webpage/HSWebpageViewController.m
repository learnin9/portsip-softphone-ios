//
//  HSAboutViewController.m
//  PortGo
//
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSWebpageViewController.h"
#import "UIBarButtonItem+HSBackItem.h"
#import "GlobalSetting.h"
#import <WebKit/WebKit.h>

@interface HSWebpageViewController ()
@property (weak, nonatomic) IBOutlet WKWebView* webView;
@end

@implementation HSWebpageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated{
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
