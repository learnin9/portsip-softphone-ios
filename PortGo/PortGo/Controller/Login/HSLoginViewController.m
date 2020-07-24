//
//  HSLoginViewController.m
//  PortGo
//
//  Created by MrLee on 14-9-22.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSLoginViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "HSAboutDetailViewController.h"
#import "HSNamesViewController.h"
#import "UIImage+HSImage.h"
#import "HSTransportViewController.h"
#import "HSZadarmaServerViewController.h"
#import "HSRegisterViewController.h"
#import "HSAdvanceOptionsViewController.h"
#import "MLTabBarController.h"
#import "Masonry.h"
#import "ScanQRViewController.h"

#import "UIColor_Hex.h"
#import "Toast+UIView.h"

#import "HttpHelper.h"

#define kCellCount 4
#define kCellHeight 44

@interface HSLoginViewController () <
    UITextFieldDelegate, HSNamesViewControllerDelegate,
    HSAdvanceOptionsViewControllerDelegate, UINavigationBarDelegate,
    HSZadarmaServerViewControllerDelegate, ScanDelegateProtocol> {
  MBProgressHUD *_HUD;

  NSMutableArray *mAccountArray;

  NSMutableArray *mateArray;

  BOOL _acountListOpen;

  NSArray *_optionsArray;

  NSIndexPath *_indexPath;

  UIView *_dimView;
  BOOL _IsLoginOut; // use has login,but click out.

  BOOL _savePassword;

  Account *lastAccount;
}

// PortGo7 UI  ===============
@property(weak, nonatomic) IBOutlet UIImageView *imageLogo1;

@property(weak, nonatomic) IBOutlet UITextField *userNameTextField1;

@property(weak, nonatomic) IBOutlet UITableView *usernameTableView;

@property(weak, nonatomic) IBOutlet UITextField *passwordTextField1;

@property(weak, nonatomic) IBOutlet UITextField *sipDomainTextField;

@property(weak, nonatomic) IBOutlet UIButton *savePasswordBtn;

@property(weak, nonatomic) IBOutlet UIButton *loginBtn;

@property(weak, nonatomic) IBOutlet UIButton *advanceOptions;

@property(weak, nonatomic) IBOutlet UILabel *savePasswordLabel;

@property(weak, nonatomic) IBOutlet UIScrollView *bgScrollView;

// PortGo6 UI ==================
@property(weak, nonatomic) IBOutlet UIView *bgcontentView;

@property(weak, nonatomic) IBOutlet UIImageView *imageLogo;

@property(weak, nonatomic) IBOutlet UIView *userNameView;
@property(weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property(weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property(weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property(weak, nonatomic) IBOutlet UITextField *sipServerTextField;
@property(weak, nonatomic) IBOutlet UITextField *serverPortTextField;

@property(weak, nonatomic) IBOutlet UIView *saveAccountView;
@property(weak, nonatomic) IBOutlet UILabel *saveAccountLabel;
@property(weak, nonatomic) IBOutlet UISwitch *saveAccountSwitch;
@property(weak, nonatomic) IBOutlet UIView *showAdvanceView;
@property(weak, nonatomic) IBOutlet UILabel *showAdvanceLabel;
@property(weak, nonatomic) IBOutlet UIButton *showAdvanceButton;

@property(weak, nonatomic) IBOutlet UIView *passwordView;
@property(weak, nonatomic) IBOutlet UIView *displayNameView;
@property(weak, nonatomic) IBOutlet UIView *serverView;
@property(weak, nonatomic) IBOutlet UIView *serverPortView;
@property(strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property(strong, nonatomic) IBOutlet UITableView *optionsView;
@property(weak, nonatomic) IBOutlet UIButton *loginButton;
@property(weak, nonatomic) IBOutlet UIButton *registerButton;
@property(weak, nonatomic) IBOutlet UIButton *forgotPWSButton;
@property(weak, nonatomic) IBOutlet UIButton *existUserButton;
@property(weak, nonatomic) IBOutlet UILabel *noteLabel;
@property(weak, nonatomic) IBOutlet UIButton *scaner;

@property UILabel *incLabel;
@property UILabel *incLabel2;

@end

@implementation HSLoginViewController

- (void)navigationBar:(UINavigationBar *)navigationBar
           didPopItem:(UINavigationItem *)item {
  navigationBar.hidden = YES;
}

- (void)initWidget {
#ifdef QR_CODE
  _scaner.hidden = false;
#endif
  _userNameTextField1.attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:NSLocalizedString(@"UserName", @"UserName")
          attributes:@{
            NSForegroundColorAttributeName : UIColor.lightGrayColor
          }];

  _passwordTextField1.attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:NSLocalizedString(@"Password", @"Password")
          attributes:@{
            NSForegroundColorAttributeName : UIColor.lightGrayColor
          }];

  _sipDomainTextField.attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:NSLocalizedString(@"SIP Server", @"SIP Server")
          attributes:@{
            NSForegroundColorAttributeName : UIColor.lightGrayColor
          }];

  //    _sipServerTextField.placeholder = NSLocalizedString(@"SIP Server", @"SIP
  //    Server");
  //    _serverPortTextField.placeholder = NSLocalizedString(@"Server Port",
  //    @"Server Port");

  _loginBtn.layer.cornerRadius = 3;
  _loginBtn.enabled = NO;

  //    _loginBtn.layer.shadowColor = [UIColor lightGrayColor].CGColor;
  //    _loginBtn.layer.shadowOffset = CGSizeMake(0.0, 5.0);
  //    _loginBtn.layer.shadowOpacity = YES;

  [_loginBtn setTitle:NSLocalizedString(@"Sign In", @"Sign In")
             forState:UIControlStateNormal];
  [_advanceOptions setTitleColor:MAIN_COLOR forState:UIControlStateNormal];

  _savePasswordLabel.text = NSLocalizedString(@"Remember me", @"Remember me");
  _savePasswordLabel.textAlignment = NSTextAlignmentLeft;

  //    _showAdvanceLabel.text = NSLocalizedString(@"Show Advanced Options",
  //    @"Show Advanced Options");
}

int userNameLen = 64; //用户的id，默认t64个字符长度
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
#ifdef MAX_USERNAME_LENGTH
  userNameLen = MAX_USERNAME_LENGTH;
#endif

  // textField当前的
  if (textField == _userNameTextField1) {
    if (range.location >= userNameLen) // MAX_USERNAME_LENGTH为最大字数
    {
      if (textField.text.length > userNameLen) {
        textField.text = [textField.text substringToIndex:userNameLen];
      }
      NSString *maxLenTips = NSLocalizedString(@"Name MaxLen", "Max len is %d");
      [self.view makeToast:[NSString stringWithFormat:maxLenTips, userNameLen]
                  duration:1.0
                  position:@"center"];
      return FALSE;
    }
  }
  return TRUE;
}
- (void)addRegisterStateObserver {
  NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
  [notification addObserver:self
                   selector:@selector(onRegisterState:)
                       name:REGISTER_STATE
                     object:nil];
}

- (void)awakeFromNib {
  [super awakeFromNib];
  self.savePasswordLabel.font = [UIFont systemFontOfSize:13];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  //     [self.optionsView reloadData];
}

- (IBAction)ScanQR:(id)sender {

  ScanQRViewController *scancon = [[ScanQRViewController alloc] init];
  scancon.scanDelegate = self;
  scancon.modalPresentationStyle = UIModalPresentationFullScreen;
  [self presentViewController:scancon animated:YES completion:nil];
}

- (void)scanFinish:(NSString *)result {
  NSString *KEY_DIS = @"display_name";
  NSString *KEY_NAME = @"extension_number";
  NSString *KEY_PWD = @"extension_password";
  NSString *KEY_WEB_PWD = @"web_access_password";
  NSString *KEY_DOMAIN = @"sip_domain";
  NSString *KEY_TRANSPORT = @"transports";
  NSString *KEY_VOICE_MAIL = @"voicemail_number";
  NSString *KEY_MAIL = @"email";
  NSString *KEY_SVR_PUBLIC = @"pbx_public_ip";
  NSString *KEY_SVR_PRIVATE = @"pbx_private_ip";
  NSString *KEY_TRANS_PORT = @"port";
  NSString *KEY_TRANS_PROTOCOL = @"protocol";
  NSString *KEY_SVR_OUTBOUND = @"outbound_proxy";

  NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
  NSError *err;
  NSDictionary *diction =
      [NSJSONSerialization JSONObjectWithData:jsonData
                                      options:NSJSONReadingMutableContainers
                                        error:&err];
  if (!err) {
    NSString *username =
        [[diction valueForKey:KEY_NAME] isKindOfClass:NSString.class]
            ? [diction valueForKey:KEY_NAME]
            : nil;
    NSString *disname =
        [[diction valueForKey:KEY_DIS] isKindOfClass:NSString.class]
            ? [diction valueForKey:KEY_DIS]
            : nil;
    NSString *password =
        [[diction valueForKey:KEY_PWD] isKindOfClass:NSString.class]
            ? [diction valueForKey:KEY_PWD]
            : nil;
    NSString *sipdomain =
        [[diction valueForKey:KEY_DOMAIN] isKindOfClass:NSString.class]
            ? [diction valueForKey:KEY_DOMAIN]
            : nil;
    NSString *server =
        [[diction valueForKey:KEY_SVR_PUBLIC] isKindOfClass:NSString.class]
            ? [diction valueForKey:KEY_SVR_PUBLIC]
            : nil;
    NSString *outserver =
        [[diction valueForKey:KEY_SVR_OUTBOUND] isKindOfClass:NSString.class]
            ? [diction valueForKey:KEY_SVR_OUTBOUND]
            : nil;
    NSString *voicemail =
        [[diction valueForKey:KEY_VOICE_MAIL] isKindOfClass:NSString.class]
            ? [diction valueForKey:KEY_VOICE_MAIL]
            : @"";
    NSArray *transport =
        [[diction valueForKey:KEY_TRANSPORT] isKindOfClass:NSArray.class]
            ? [diction valueForKey:KEY_TRANSPORT]
            : nil;

    NSMutableDictionary *transkv = [NSMutableDictionary new];
    if (username == nil ||
        [username stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                .length == 0 ||
        sipdomain == nil ||
        [sipdomain stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                .length == 0 ||
        password == nil ||
        [password stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                .length == 0) {

      NSString *invalideQr =
          NSLocalizedString(@"invalide qr code", "Invalide QR code");
      [self.view makeToast:invalideQr duration:1.5 position:@"center"];
    } else {
      for (NSDictionary *trans in transport) {
        NSString *key = [[trans valueForKey:KEY_TRANS_PROTOCOL]
                            isKindOfClass:NSString.class]
                            ? [trans valueForKey:KEY_TRANS_PROTOCOL]
                            : nil;
        NSString *value =
            [[trans valueForKey:KEY_TRANS_PORT] isKindOfClass:NSString.class]
                ? [trans valueForKey:KEY_TRANS_PORT]
                : nil;
        
          NSScanner* scan = [NSScanner scannerWithString:value];

          int scanport;
        if (key != nil && value != nil) {
            if(!([scan scanInt:&scanport] && [scan isAtEnd])){
                scanport =5060;
            }
            [transkv setObject:[NSNumber numberWithInt:scanport] forKey:key];
        }
      }
      NSString *transportType = @"UDP";
      NSNumber *port = [NSNumber numberWithInt:5060];
      if ([transkv.allKeys containsObject:@"UDP"]) {
        transportType = @"UDP";
        port = [transkv valueForKey:transportType];
      } else if ([transkv.allKeys containsObject:@"TCP"]) {
        transportType = @"TCP";
        port = [transkv valueForKey:transportType];
      } else if ([transkv.allKeys containsObject:@"TLS"]) {
        transportType = @"TLS";
        port = [transkv valueForKey:transportType];
      } else if ([transkv.allKeys containsObject:@"PERS_UDP"]) {
        transportType = @"PERS_UDP";
        port = [transkv valueForKey:transportType];
      } else if ([transkv.allKeys containsObject:@"PERS_TCP"]) {
        transportType = @"PERS_TCP";
        port = [transkv valueForKey:transportType];
      }

      if (server ==
          nil) { //集群版是KEY_SVR_PUBLIC
                 //，单机版是KEY_SVR_OUTBOUND。没找到集群版的，就用单机版的。
        server = outserver;
      }

      if (disname != nil) {
        disname =
            [disname stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
      }

      _mAccount = [[Account alloc] initWithName:0
                                       UserName:username
                                    DisplayName:disname
                                       AuthName:@""
                                       Password:password
                                     UserDomain:sipdomain
                                      SIPServer:server
                                  SIPServerPort:port.intValue
                                  TransportType:transportType
                                 OutboundServer:@""
                             OutboundServerPort:0
                                        Actived:0];

      _mAccount.presenceAgent = DEFALUT_OPTIONS_NATT_PRESENCE_AGENT;
      _mAccount.subscribeRefresh = DEFAULT_OPTIONS_NATT_SUBSCRIBE_REFRESH;
      _mAccount.publishRefresh = DEFAULT_OPTIONS_NATT_PUBLISH_REFRESH;
      _mAccount.enableSTUN = DEFALUT_OPTIONS_NATT_USE_STUN;
      _mAccount.STUNServer = DEFALUT_OPTIONS_NATT_STUN_SERVER;
      _mAccount.STUNPort = DEFALUT_OPTIONS_NATT_STUN_PORT;
      _mAccount.useCert = DEFAULT_OPTIONS_NATT_USE_CERT;
      _mAccount.voiceMail = voicemail;
      [self setAccountInfo];
      [databaseManage saveActiveAccount:_mAccount reset:YES];
      [self loginButtonClick:nil];
    }

  } else {
    NSString *invalideQr =
        NSLocalizedString(@"invalide qr code", "Invalide QR code");
    [self.view makeToast:invalideQr duration:1.5 position:@"center"];
  }
}

- (void)viewDidAppear:(BOOL)animated {

  //    NSLog(@"UIApplication sharedApplication].applicationState
  //    viewDidAppear=%ld",[UIApplication sharedApplication].applicationState);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  UIColor *bkColor;
  if (@available(iOS 11.0, *)) {
    bkColor = [UIColor colorNamed:@"mainBKColor"];
  } else {
    bkColor = [UIColor whiteColor];
  }

  self.bgcontentView.backgroundColor = bkColor;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  mAccountArray = [databaseManage selectAllAccount]; //加载账户列表
  mateArray = [[NSMutableArray alloc] initWithArray:mAccountArray];

  _bgcontentView.layer.cornerRadius = 5.0;
  _bgcontentView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
  _bgcontentView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
  _bgcontentView.layer.shadowOpacity = YES;

  _usernameTableView.layer.borderWidth = 0.5;
  _usernameTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;

  [_advanceOptions setTitle:NSLocalizedString(@"Advance", @"Advance")
                   forState:UIControlStateNormal];

  CGSize contentsize = _bgScrollView.contentSize;
  contentsize.height =
      _bgcontentView.frame.origin.y + _bgcontentView.frame.size.height + 50;
  [_bgScrollView setContentSize:contentsize];

  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(resignTextFieldFirstResponder)];
  tap.delegate = self;
  [self.bgScrollView addGestureRecognizer:tap];

  [self initWidget];
  [self addRegisterStateObserver];

  _optionsArray = [NSArray
      arrayWithObjects:NSLocalizedString(@"Names", @"Names"),
                       NSLocalizedString(@"Transport", @"Transport"),
                       NSLocalizedString(@"Enable Logging", @"Enable Logging"),
                       NSLocalizedString(@"About", @"About"), nil];

  UINavigationBar *navBar = self.navigationController.navigationBar;
  [navBar setBackgroundImage:[UIImage imageNamed:@"navigation_line.png"]
               forBarMetrics:UIBarMetricsDefault];

  if (!_mAccount) {
    _mAccount = [databaseManage selectActiveAccount];
  }

  if (!_mAccount) {
    NSString *transportType = @"UDP";
    switch (DEFALUT_OPTIONS_NETWORK_TRANSPORT) {
    case 0:
      transportType = @"UDP";
      break;
    case 1:
      transportType = @"TLS";
      break;
    case 2:
      transportType = @"TCP";
      break;
    case 3:
      transportType = @"PERS_UDP";
      break;
    case 4:
      transportType = @"PERS_TCP";
      break;
    default:
      break;
    }
    _mAccount = [[Account alloc] initWithName:0
                                     UserName:@""
                                  DisplayName:@""
                                     AuthName:@""
                                     Password:@""
                                   UserDomain:@""
                                    SIPServer:@""
                                SIPServerPort:5060
                                TransportType:transportType
                               OutboundServer:@""
                           OutboundServerPort:0
                                      Actived:0];

    _mAccount.presenceAgent = DEFALUT_OPTIONS_NATT_PRESENCE_AGENT;
    _mAccount.subscribeRefresh = DEFAULT_OPTIONS_NATT_SUBSCRIBE_REFRESH;
    _mAccount.publishRefresh = DEFAULT_OPTIONS_NATT_PUBLISH_REFRESH;
    _mAccount.enableSTUN = DEFALUT_OPTIONS_NATT_USE_STUN;
    _mAccount.STUNServer = DEFALUT_OPTIONS_NATT_STUN_SERVER;
    _mAccount.STUNPort = DEFALUT_OPTIONS_NATT_STUN_PORT;
    _mAccount.useCert = DEFAULT_OPTIONS_NATT_USE_CERT;
    _mAccount.voiceMail = @"";

    NSLog(@"_mAccount.useCert======%d", _mAccount.useCert);
  }

  self.navigationController.navigationBar.hidden = YES;
  [self setLoginButtonFrame];

  _userNameTextField1.delegate = self;
  _passwordTextField1.delegate = self;
  _sipDomainTextField.delegate = self;

  _incLabel = [[UILabel alloc] init];

  _incLabel.textColor = RGB(255, 255, 255);

  _incLabel.textAlignment = NSTextAlignmentCenter;

  _incLabel.font = [UIFont systemFontOfSize:11];

  _incLabel.text = @"Power by";

  [self.view addSubview:_incLabel];

  _incLabel.frame = CGRectMake(0, ScreenHeight - 15 - 20 - 20, ScreenWid, 20);

  if (IS_iPhoneX) {

    _incLabel.frame =
        CGRectMake(0, ScreenHeight - 15 - 20 - 20 - 20, ScreenWid, 20);
  }

  _incLabel2 = [[UILabel alloc] init];

  _incLabel2.textColor = RGB(255, 255, 255);

  _incLabel2.textAlignment = NSTextAlignmentCenter;

  _incLabel2.font = [UIFont systemFontOfSize:11];

  _incLabel2.text = @"PortSIP Solutions, Inc.";


  [self.view addSubview:_incLabel2];

  _incLabel2.frame = CGRectMake(0, ScreenHeight - 15 - 20, ScreenWid, 20);

  if (IS_iPhoneX) {

    _incLabel2.frame =
        CGRectMake(0, ScreenHeight - 15 - 20 - 20, ScreenWid, 20);
  }

  [self setAccountInfo];

  [self traitCollectionDidChange:self.traitCollection];
}

- (IBAction)switchAutoRegAction:(id)sender {
  UISwitch *switchButton = (UISwitch *)sender;
  BOOL isButtonOn = [switchButton isOn];
  if (isButtonOn) {
    databaseManage.mOptions.autoReg = 1;
  } else {
    databaseManage.mOptions.autoReg = 0;
  }
  [databaseManage saveOptions];
}

- (void)selectServer:(id)sender {
  HSZadarmaServerViewController *ctrl = [[HSZadarmaServerViewController alloc]
      initWithNibName:@"HSZadarmaServerViewController"
               bundle:nil];
  ctrl.modalPresentationStyle = UIModalPresentationFullScreen;
  ctrl.delegate = self;
  [self presentViewController:ctrl animated:YES completion:nil];
}

- (void)didSelectSIPServer:(NSDictionary *)sipServrer {
  _sipDomainTextField.text = sipServrer[@"serverName"];
  //    _serverPortTextField.text = sipServrer[@"SIPServerPort"];
  [self setLoginButtonState];
}

- (void)setLoginButtonFrame {
  if (DEVICE_IS_IPHONE4) {
    CGPoint offset = CGPointZero;
    offset.y = 40;
    _scrollView.contentOffset = offset;
  }
}

- (BOOL)setLoginButtonState {
  if (_userNameTextField1.text.length && _passwordTextField1.text.length &&
      _sipDomainTextField.text.length) {

    _loginBtn.enabled = YES;
    [_loginBtn setBackgroundColor:MAIN_COLOR];
      return true;
  } else {
    _loginBtn.enabled = NO;
    [_loginBtn setBackgroundColor:MAIN_COLOR_LIGHT];
      return false;
  }

    return false;
}

#pragma mark - HSAdvanceOptionsViewControllerDelegate
- (void)didSetOptionWith:(Account *)account {

    _mAccount = account;
    [self setAccount:_mAccount];
    NSLog(@"_mAccount._mAccount.transportType====%@", _mAccount.transportType);
}

- (void)setAccount:(Account *)account {
  _IsLoginOut = YES;

  //_mAccount = [databaseManage selectActiveAccount];

  [self setAccountInfo];
}

- (void)setAccountInfo {
  if (_mAccount.userName != nil && ![_mAccount.userName isEqualToString:@""] &&
      (_mAccount.password == nil ||
       [_mAccount.password isEqualToString:@""])) {
    // if has account, but password is nil, not save password.
    _savePasswordBtn.selected = NO;
  } else {
    _savePasswordBtn.selected = YES;
  }

  self.userNameTextField1.text = _mAccount.userName;
  self.passwordTextField1.text = _mAccount.password;
    if((_mAccount.SIPServerPort!=5060)&&([_mAccount.SIPServer isEqualToString:@"(null)"]||[[_mAccount.SIPServer stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0)){
        self.sipDomainTextField.text = [_mAccount.userDomain stringByAppendingFormat:@":%d",_mAccount.SIPServerPort];
    }else{
        self.sipDomainTextField.text = _mAccount.userDomain;
    }

  BOOL AutoLogin =
      [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoLogin"];

  if (![_mAccount.userName isEqualToString:@""] &&
      ![_mAccount.password isEqualToString:@""] &&
      ![_mAccount.userDomain isEqualToString:@""] && AutoLogin) {

    //自动登录

    NSLog(@"_userNameTextField=%@   _passwordTextField==%@   "
          @"_sipDomainTextField===%@",
          self.userNameTextField1.text, self.passwordTextField1.text,
          self.sipDomainTextField.text);

    //   NSLog(@"UIApplication
    //   sharedApplication].applicationState=%ld",[UIApplication
    //   sharedApplication].applicationState);

    if ([UIApplication sharedApplication].applicationState !=
        UIApplicationStateBackground) {

      [self loginButtonClick:nil];
    } else {
      [self loginButtonClick:nil];
    }
    _bgScrollView.hidden = true;
  }

  [self setLoginButtonState];
}

#pragma mark---------- onLoginSuccess
- (void)onRegisterState:(NSNotification *)sender {
  NSString *state = [sender object];

  if ([state isEqualToString:REGISTER_STATE_SUCCESS]) {

    UIStoryboard *mainStoryboard =
        [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MLTabBarController *tabCtrl =
        [mainStoryboard instantiateViewControllerWithIdentifier:@"Tabbar"];

    [UIApplication sharedApplication].statusBarStyle =
        UIStatusBarStyleLightContent;
    [shareAppDelegate initTabbar];

    [_HUD hide:YES];
    //重新订阅所有好友
    [contactView viewWillAppear:YES];
  } else if ([state isEqualToString:REGISTER_STATE_REGISTERING]) {

  } else {
    NSDictionary *userInfoDict = sender.userInfo;
    int errorCode = [userInfoDict[@"errorCode"] intValue];
    NSString *errorText = userInfoDict[@"statusText"];
    [self registerFailWithErrorcode:errorCode text:errorText];
  }
}

#pragma mark---------- onLoginFailed
- (void)registerFailWithErrorcode:(int)errorCode text:(NSString *)errorText {
  _dimView = [[UIView alloc] initWithFrame:shareAppDelegate.window.frame];
  UITapGestureRecognizer *tapGesture =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(onTap:)];
  [_dimView addGestureRecognizer:tapGesture];

  _HUD.mode = MBProgressHUDModeText;
  //_HUD.labelText = [NSString stringWithFormat:@"%d: %@", errorCode,
  //errorText];
  _HUD.labelText = NSLocalizedString(@"Unable to login", @"Unable to login");
  _HUD.detailsLabelText =
      [NSString stringWithFormat:@"%d: %@", errorCode, errorText];
  [_HUD addSubview:_dimView];
  _bgScrollView.hidden = false;
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AutoLogin"];
  //注册失败也进入主界面
  //[[NSNotificationCenter defaultCenter] postNotificationName:REGISTER_STATE
  //object:REGISTER_STATE_SUCCESS userInfo:nil];
}

- (void)onTap:(id)sender {
  [_dimView removeFromSuperview];
  _HUD.hidden = YES;
}

- (void)onTapCancelRegist:(id)sender {
  [_dimView removeFromSuperview];
  _HUD.hidden = YES;
  _bgScrollView.hidden = false;
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AutoLogin"];

  [portSIPEngine loginOut];
}

- (void)processRegitsterToServer {

  int ret = [shareAppDelegate registerWithAccount:_mAccount];

  NSLog(@"1=%@ 2=%@ 3=%@ 4 =%@", _mAccount.userName, _mAccount.password,
        _mAccount.SIPServer, _mAccount.transportType);

  NSLog(@"ret======%d", ret);

  if (ret == -1) {
    [self registerFailWithErrorcode:ret
                               text:[NSString stringWithFormat:
                                                  @"%@...",
                                                  NSLocalizedString(
                                                      @"Initial SDK error",
                                                      @"Initial SDK error")]];
  } else if (ret == -2) {
    [self registerFailWithErrorcode:ret
                               text:[NSString stringWithFormat:
                                                  @"%@...",
                                                  NSLocalizedString(
                                                      @"Account info error",
                                                      @"Account info error")]];
  } else if (ret == -3) {
    [self
        registerFailWithErrorcode:ret
                             text:[NSString
                                      stringWithFormat:@"%@...",
                                                       NSLocalizedString(
                                                           @"NetWork error",
                                                           @"NetWork error")]];
  }

  NSLog(@"save accout2");

  if (ret == 0) {
    [databaseManage saveActiveAccount:_mAccount reset:YES];

    //   shareAppDelegate.portSIPHandle.mAccount = _mAccount ;
    shareAppDelegate.account = _mAccount;
  }
}

#pragma mark - regitsterToServer

- (void)regitsterToServer {
    if([_sipDomainTextField isFirstResponder]){
        [_sipDomainTextField endEditing:YES];
    }
    _mAccount.userName = [self.userNameTextField1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _mAccount.password = [self.passwordTextField1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _sipDomainTextField.text = [self.sipDomainTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSLog(@"_mAccount.userDomain==%@", _mAccount.userDomain);

   _mAccount.SIPServer = [_mAccount.SIPServer stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
  if (_mAccount.transportType == nil ||
      [_mAccount.transportType isEqualToString:@""]) {
    _mAccount.transportType = @"UDP";
  }

  if (_mAccount.displayName == nil) {
    _mAccount.displayName = @"";
  }

  if (_mAccount.authName == nil) {
    _mAccount.authName = @"";
  }

  if (_mAccount.userDomain == nil) {
    _mAccount.userDomain = @"";
  }

  NSString *password = _mAccount.password;
  if (!_savePasswordBtn.isSelected) {
    _mAccount.password = @"";
  }

  NSLog(@"transportType=%@", _mAccount.transportType);
  NSLog(@"displayName=%@", _mAccount.displayName);

  _mAccount.password = password;

  lastAccount = _mAccount;

#ifndef ENABLE_AUTO_PROVISIONING
  dispatch_async(dispatch_get_main_queue(), ^{
    [self processRegitsterToServer];
  });
#endif
}

#ifdef ENABLE_AUTO_PROVISIONING
- (void)ReceiveSIPAccount:(BOOL)status {
  if (status) {
    dispatch_async(dispatch_get_main_queue, ^{
      [self processRegitsterToServer];
    });
  } else {
    _dimView = [[UIView alloc] initWithFrame:shareAppDelegate.window.frame];
    UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(onTap:)];
    [_dimView addGestureRecognizer:tapGesture];

    _HUD.mode = MBProgressHUDModeText;
    _HUD.labelText = [NSString stringWithFormat:@"The account is invalid."];
    [_HUD addSubview:_dimView];
  }
}
#endif

- (BOOL)isPureInt:(NSString *)string {
  NSScanner *scan = [NSScanner scannerWithString:string];
  int val;
  return [scan scanInt:&val] && [scan isAtEnd];
}
- (IBAction)savePasswordClick:(id)sender {
  UIButton *btn = (UIButton *)sender;
  BOOL isBtnOn = btn.isSelected;
  if (isBtnOn) {
    _savePasswordBtn.selected = NO;
    databaseManage.mOptions.autoReg = 1;
  } else {
    _savePasswordBtn.selected = YES;
    databaseManage.mOptions.autoReg = 0;
  }
  [databaseManage saveOptions];
}

#pragma mark - loginButtonClick

- (IBAction)loginButtonClick:(id)sender {
    if(![self setLoginButtonState]){
        return;
    }

  _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    if(sender!=nil){
        _HUD.color =nil;
        _HUD.labelText = [NSString
                          stringWithFormat:@"%@...",
                          NSLocalizedString(@"Signing in", @"Signing in")];
    }else{
        _HUD.color =UIColor.clearColor;
        _HUD.labelText =nil;
    }

  _dimView = [[UIView alloc] initWithFrame:shareAppDelegate.window.frame];
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCancelRegist:)];
  [_dimView addGestureRecognizer:tapGesture];

  [self.view addSubview:_HUD];

  [_HUD addSubview:_dimView];
  [_HUD show:YES];

  [self regitsterToServer];


  //保存变量判断是否自动登录
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AutoLogin"];
}

- (IBAction)registerButtonClick:(id)sender {
  HSRegisterViewController *ctrl = [[HSRegisterViewController alloc]
      initWithNibName:@"HSRegisterViewController"
               bundle:nil];
  ctrl.modalPresentationStyle = UIModalPresentationFullScreen;
  [self presentViewController:ctrl animated:YES completion:nil];
}

- (IBAction)existUserButtonClick:(id)sender {

}

- (IBAction)forgetButtonClick:(id)sender {
  HSRegisterViewController *ctrl = [[HSRegisterViewController alloc]
      initWithNibName:@"HSRegisterViewController"
               bundle:nil];
  ctrl.modalPresentationStyle = UIModalPresentationFullScreen;
  [self presentViewController:ctrl animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

  NSLog(@"LogingSuccess");
  if ([segue.identifier isEqualToString:@"LogingSuccess"]) {
    UITabBarController *barCtr = segue.destinationViewController;
    shareAppDelegate.window.rootViewController = barCtr;
  }
}

#pragma mark - HSNamesViewControllerDelegate
- (void)didWriteDoneWithDisplayName:(NSString *)displayName
                         AuthorName:(NSString *)authorName
                             Domain:(NSString *)domain {
  _mAccount.displayName = displayName;
  _mAccount.authName = authorName;
  _mAccount.userDomain = domain;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  if (_acountListOpen) {
    //    return mAccountArray.count;

    return mateArray.count;
  }
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  static NSString *ID = @"ID";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                  reuseIdentifier:ID];
  }

  cell.accessoryView = nil;

  UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
  deleteButton.frame = CGRectMake(0, 12, 20, 20);
  [deleteButton setImage:[UIImage imageNamed:@"login_user-del"]
                forState:UIControlStateNormal];
  [deleteButton setImage:[UIImage imageNamed:@"login_user-del_select"]
                forState:UIControlStateHighlighted];
  deleteButton.tag = indexPath.row + 100;
  [deleteButton addTarget:self
                   action:@selector(deleteUserNameAction:)
         forControlEvents:UIControlEventTouchUpInside];
  cell.accessoryView = deleteButton;

  [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
  [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14.0]];

  //     Account *account = mAccountArray[indexPath.row];

  Account *account = mateArray[indexPath.row];

  if (account.displayName && account.displayName.length > 0) {
    cell.textLabel.text = account.displayName;
  } else {
    cell.textLabel.text = account.userName;
  }

  NSRange rangemata =
      [cell.textLabel.text rangeOfString:_userNameTextField1.text];

  NSString *content = cell.textLabel.text;

  NSMutableAttributedString *attributeString =
      [[NSMutableAttributedString alloc] initWithString:content];

  [attributeString setAttributes:@{
    NSForegroundColorAttributeName : RGB(75, 194, 255),
    NSFontAttributeName : [UIFont systemFontOfSize:16.f]
  }
                           range:rangemata];

  cell.textLabel.attributedText = attributeString;

  if (account.userDomain && account.userDomain.length > 0) {
    //        cell.detailTextLabel.text = [NSString
    //        stringWithFormat:@"sip:%@@%@", account.userName,
    //        account.userDomain];

    if (account.SIPServerPort != 0 && account.SIPServerPort != 5060) {

      cell.detailTextLabel.text = [NSString
          stringWithFormat:@"%@:%d", account.userDomain, account.SIPServerPort];

    } else {

      cell.detailTextLabel.text =
          [NSString stringWithFormat:@"%@", account.userDomain];
    }

  } else {
    //        cell.detailTextLabel.text = [NSString
    //        stringWithFormat:@"sip:%@@%@", account.userName,
    //        account.SIPServer];

    if (account.SIPServerPort != 0 && account.SIPServerPort != 5060) {

      cell.detailTextLabel.text = [NSString
          stringWithFormat:@"%@:%d", account.SIPServer, account.SIPServerPort];
    } else {

      cell.detailTextLabel.text =
          [NSString stringWithFormat:@"%@", account.SIPServer];
    }
  }

  //    NSString *content2 = cell.detailTextLabel.text;
  //
  //    NSMutableAttributedString *attributeString2  =
  //    [[NSMutableAttributedString alloc]initWithString:content2];
  //
  //    [attributeString2 setAttributes:@{NSForegroundColorAttributeName:RGB(75,
  //    194, 255),NSFontAttributeName:[UIFont systemFontOfSize:14.f]}
  //    range:NSMakeRange(rangemata.location+4, rangemata.length)];
  //
  //
  //    cell.detailTextLabel.attributedText = attributeString2;

  return cell;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    Account *account = mateArray[indexPath.row];
    if (account) {
      [databaseManage deleteAccount:account.accountId];
      if ([_userNameTextField1.text isEqualToString:account.userName]) {
        _userNameTextField1.text = @"";
        _passwordTextField1.text = @"";
        _sipDomainTextField.text = @"";
      }
    }

    [mateArray removeObjectAtIndex:indexPath.row];
    mAccountArray = mateArray;

    [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                     withRowAnimation:UITableViewRowAnimationFade];
  }
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  _mAccount = mateArray[indexPath.row];
  [self setAccountInfo];

  //   [self setAccount:_mAccount];

  if (indexPath.row != 0) {
    [mateArray exchangeObjectAtIndex:0 withObjectAtIndex:indexPath.row];
    [_usernameTableView reloadData];
  }

  [self resignTextFieldFirstResponder];
}

- (void)deleteUserNameAction:(UIButton *)sender {

  //   NSLog(@"点击第%d行",sender.tag);
  Account *account = mateArray[sender.tag - 100];

  [databaseManage deleteAccount:account.accountId];
  [mateArray removeObjectAtIndex:sender.tag - 100];

  mAccountArray = [databaseManage selectAllAccount]; //加载账户列表

  //    NSIndexPath *index = [NSIndexPath indexPathForRow:sender.tag
  //    inSection:0];
  // [_usernameTableView deleteRowsAtIndexPaths:@[index]
  // withRowAnimation:UITableViewRowAnimationNone];

  [self mata];

  // [_usernameTableView reloadData];

  if (mateArray.count == 0) {

    _usernameTableView.hidden = YES;
  }
}

#pragma mark -
#pragma mark advance Click

- (IBAction)advanceOptionClick:(id)sender {
    //先结束sipDomain编辑状态，判断是否需要重置高级选项，再进高级界面。
    //否则，会先进高级界面，后结束编辑状态，导致对sipdomain的判断失效
  [_sipDomainTextField endEditing:YES];

  HSAdvanceOptionsViewController *advance = [[HSAdvanceOptionsViewController alloc]
          initWithNibName:@"HSAdvanceOptionsViewController" bundle:nil];
  advance.modalPresentationStyle = UIModalPresentationFullScreen;

  advance.account = _mAccount;
  //    NSLog(@"传过去的account:%@", _mAccount);
  advance.delegate = self;
  advance.username = self.userNameTextField1.text;

  [self presentViewController:advance animated:YES completion:^{ }];
       
}

- (void)mata {

  [mateArray removeAllObjects];

  for (Account *account in mAccountArray) {

    if (account.displayName && account.displayName.length > 0) {

      if ([account.displayName rangeOfString:_userNameTextField1.text]
              .location != NSNotFound) {

        [mateArray addObject:account];
      }

    } else {

      if ([account.userName rangeOfString:_userNameTextField1.text].location !=
          NSNotFound) {

        [mateArray addObject:account];
      }
    }
  }

  if (_userNameTextField1.text.length == 0) {

    //     _usernameTableView .hidden = YES;

    mateArray = [databaseManage selectAllAccount];

    if (mateArray.count == 0) {

      _usernameTableView.hidden = YES;
    }

  } else {

    _usernameTableView.hidden = NO;

    if (mateArray.count == 0) {

      _usernameTableView.hidden = YES;
    }
  }

  [_usernameTableView reloadData];
}

- (IBAction)textFieldDidChanged:(id)sender {
  if (sender == _userNameTextField1) { //账号输入改变 密码输入框内容清除
      _passwordTextField1.text = @"";
      [self mata];
  }else if(sender==_sipDomainTextField){
      NSString* userDomain = [_sipDomainTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      NSString* userName = [_userNameTextField1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      NSString* userPwd = [_passwordTextField1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      NSString* oriSipDomain;
      if((_mAccount.SIPServerPort!=5060)&&([_mAccount.SIPServer isEqualToString:@"(null)"]||[[_mAccount.SIPServer stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0)){
          oriSipDomain = [_mAccount.userDomain stringByAppendingFormat:@":%d",_mAccount.SIPServerPort];
      }else{
          oriSipDomain = _mAccount.userDomain;
      }
      
       if(userDomain.length>0&&![userDomain isEqual:oriSipDomain]){
          NSLog(@"advanceOptionClick textFieldDidChanged");
          NSString* sipServer=@"";
          int sipServerPort=5060;

          if ([userDomain rangeOfString:@":"].location !=
            NSNotFound) {
              NSArray *arr = [userDomain componentsSeparatedByString:@":"];
              sipServer = arr[0];
              userDomain = arr[0];
              sipServerPort= [arr[1] intValue];
          }
          _mAccount = [[Account alloc] initWithName:0
                                           UserName:userName
                                        DisplayName:@""
                                           AuthName:@""
                                           Password:userPwd
                                         UserDomain:userDomain
                                          SIPServer:sipServer
                                      SIPServerPort:sipServerPort
                                      TransportType:@"UDP"
                                     OutboundServer:@""
                                 OutboundServerPort:0
                                            Actived:0];

          _mAccount.presenceAgent = DEFALUT_OPTIONS_NATT_PRESENCE_AGENT;
          _mAccount.subscribeRefresh = DEFAULT_OPTIONS_NATT_SUBSCRIBE_REFRESH;
          _mAccount.publishRefresh = DEFAULT_OPTIONS_NATT_PUBLISH_REFRESH;
          _mAccount.enableSTUN = DEFALUT_OPTIONS_NATT_USE_STUN;
          _mAccount.STUNServer = DEFALUT_OPTIONS_NATT_STUN_SERVER;
          _mAccount.STUNPort = DEFALUT_OPTIONS_NATT_STUN_PORT;
          _mAccount.useCert = DEFAULT_OPTIONS_NATT_USE_CERT;
       }
  }
    
  [self setLoginButtonState];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
  NSLog(@"%@", NSStringFromClass([touch.view class]));
  if ([NSStringFromClass([touch.view class])
          isEqualToString:@"UITableViewCellContentView"]) {
    return NO;
  }
  return YES;
}

- (void)resignTextFieldFirstResponder {
  [UIView animateWithDuration:.30
                   animations:^{
                     [_userNameTextField1 resignFirstResponder];
                     [_passwordTextField1 resignFirstResponder];
                     [_sipDomainTextField resignFirstResponder];
                   }];
}

//输入框编辑完成以后，将视图恢复到原始状态
- (void)textFieldDidEndEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.25
                   animations:^{
                     [_bgScrollView setContentOffset:CGPointZero];
                   }];

  //    _acountListOpen = NO;
  //    [_usernameTableView reloadData];
  _usernameTableView.hidden = YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.25
                   animations:^{
                     [_bgScrollView setContentOffset:CGPointMake(0, 70)];
                   }];
  if (textField == _userNameTextField1) {
    if (mateArray.count > 0) {

      _acountListOpen = YES;
      [_usernameTableView reloadData];
      _usernameTableView.hidden = NO;
    }
  }
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
