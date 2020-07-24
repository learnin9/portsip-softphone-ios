//
//  HSAboutViewController.m
//  PortGo
//
//  Created by MrLee on 14-9-25.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSAboutDetailViewController.h"
#import "UIBarButtonItem+HSBackItem.h"
#import <WebKit/WebKit.h>
#import "AppDelegate.h"

@interface HSAboutDetailViewController ()
{
    
    NSString *strWebSite;
    
}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property WKWebView* aboutWebview;
@end

@implementation HSAboutDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"About", @"About");
    self.titleLabel.textColor = [UIColor colorWithRed:43.0/255 green:177.0/255 blue:243.0/255 alpha:1];
    self.title = NSLocalizedString(@"About", @"About");
    [self traitCollectionDidChange:self.traitCollection];
    
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bkColor = [UIColor whiteColor];
    }
    
    self.view.backgroundColor = bkColor;
}
- (void)viewWillAppear:(BOOL)animated{
    
}

-(void)setwebview{
    _aboutWebview = [[WKWebView alloc]init];
    _aboutWebview.frame = CGRectMake(0, 0, ScreenWid, ScreenHeight-64);
    
    if (_inadvance) {
        _aboutWebview.frame = CGRectMake(0, 64, ScreenWid, ScreenHeight-64);
    }
    
    NSString *nsLang = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"]  objectAtIndex:0];
    NSString* urlstr ;
    
    if ([nsLang rangeOfString:@"CN"].location !=NSNotFound) {
        
        urlstr = @"http://www.portsip.cn/about/about.html";
    }
    else
    {
        
        urlstr = @"https://www.portsip.com/about/about.html";
        
    }
    
    
    [_aboutWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstr]]];
    [self.view addSubview:_aboutWebview];
    
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

- (void)loadView
{
    [super loadView];
    
    int CIY = 64 + 30;
    if (_topView == nil) {
        CIY = 30;
    }
    
    UIImageView *companyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_logo"]];
    companyImage.frame = CGRectMake((MAIN_SCREEN_WIDTH - 120) / 2, CIY, 120.0f, 120.0f);
    [self.view addSubview:companyImage];
    
    NSString *strVersion = @"";
    NSString *strAboutUS = @"";
    
    strWebSite = @"";
    NSString *detailUs = [NSString stringWithFormat:@"Built base on PortSIP VoIP %@", [shareAppDelegate.portSIPHandle getVersion]];
    strVersion = [NSString stringWithFormat:@"Version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    strWebSite = @"https://www.portsip.com";
    
    
    
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, companyImage.frame.origin.y + companyImage.frame.size.height + 20, MAIN_SCREEN_WIDTH, 20.0f)];
    
    version.textAlignment = NSTextAlignmentCenter;
    version.text = strVersion;
    version.font = [UIFont systemFontOfSize:19.0];
    [self.view addSubview:version];
    
    
    UILabel *aboutUs = [[UILabel alloc] initWithFrame:CGRectMake(50,200,ScreenWid-100,200)];
    NSString * str = [NSString stringWithFormat:@"%@\n%@",strWebSite,detailUs];
    
    aboutUs.text = str;
    aboutUs.textColor = [UIColor lightGrayColor];
    aboutUs.font = [UIFont systemFontOfSize:15];
    aboutUs.numberOfLines = 0;
    aboutUs.textAlignment =NSTextAlignmentCenter;
    
    [self.view addSubview:aboutUs];
    
    
    UILabel *webSite = [[UILabel alloc] initWithFrame:CGRectMake(0,ScreenHeight-30-64-50*2,ScreenWid,30+50)];
    
    webSite.textAlignment = NSTextAlignmentCenter;
    webSite.textColor = [UIColor lightGrayColor];
    webSite.font = [UIFont systemFontOfSize:15.0];
    
    webSite.numberOfLines = 0;
    
    [self.view addSubview:webSite];
    
    UITapGestureRecognizer *ges0 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(weibo)];
    [webSite addGestureRecognizer:ges0];
    webSite .userInteractionEnabled = YES;
    
    webSite.text = [NSString stringWithFormat:@"%@\n%@\n%@",@"长沙市博瞻信息技术有限公司",@"Copyright @2017 PortSIP Solutions, Inc.",@"All Rights Reserved."];
    
}
-(void)weibo{
    NSURL *url = [NSURL URLWithString:strWebSite];
    [[UIApplication sharedApplication] openURL:url];
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
