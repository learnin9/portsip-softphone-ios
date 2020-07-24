//
//  FirstViewController.m
//  PortGo
//
//  Created by Joe Lepple on 3/25/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "NumpadViewController.h"
#import "AppDelegate.h"
#import "NSString+HSFilterString.h"
#import "Contact.h"
#import "AddorEditViewController.h"
#import "History.h"
#import "DataBase.h"
#import "Person.h"
#import "UIColor_Hex.h"
#import "CzxAccountSettingsController.h"
#import "CallForwardingViewController.h"

#import "JRDB.h"
#import "callListModel.h"

#import "Toast+UIView.h"

#import "Masonry.h"
#import "ScanQRViewController.h"

#import "testAMRViewController.h"

#define kTAGStar		10
#define kTAGSharp		11
#define kTAGAudioCall	12
#define kTAGDelete		13
#define kTAGMessages	14
#define kTAGVideoCall	15

@interface NumpadViewController ()<ABPeoplePickerNavigationControllerDelegate, UIActionSheetDelegate, URLAsyncGetDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate>
{
    ABPeoplePickerNavigationController *_picker;
    NSMutableArray *_phoneM;
    int _mSessionId;
    
    NSMutableArray *searchResult;
    NSMutableArray *allnumbers;
    
    CGFloat lastContentOffset;
    
    UILabel * numberlab;
    Account *_mAccount;
    
}

@property (weak, nonatomic) IBOutlet UILabel *accountInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UITableView *searchTableview;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *dtmfView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numericaSet;
@property (weak, nonatomic) IBOutlet UIButton *videoCallButton;
@property (weak, nonatomic) IBOutlet UIButton *audioCallButton;
@property (weak, nonatomic) IBOutlet UIButton *transferButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

@property UIImageView *upArrowimageview;

//通话中的呼叫转移
@property UIButton * callforbutton;


//VM小红点
@property UILabel*  VMcountLabel;
@property (weak, nonatomic) IBOutlet UIButton *ScanQRButton;
@property (weak, nonatomic) IBOutlet UIButton *num1;
@property (weak, nonatomic) IBOutlet UIButton *num2;
@property (weak, nonatomic) IBOutlet UIButton *num3;
@property (weak, nonatomic) IBOutlet UIButton *num4;
@property (weak, nonatomic) IBOutlet UIButton *num5;
@property (weak, nonatomic) IBOutlet UIButton *num6;
@property (weak, nonatomic) IBOutlet UIButton *num7;
@property (weak, nonatomic) IBOutlet UIButton *num8;
@property (weak, nonatomic) IBOutlet UIButton *num9;
@property (weak, nonatomic) IBOutlet UIButton *numX;
@property (weak, nonatomic) IBOutlet UIButton *num0;
@property (weak, nonatomic) IBOutlet UIButton *numJ;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@end


@implementation NumpadViewController

-(void)onInviteStatus{
    //if(self.beingPresented){
    [self refreshReturnButtonState];
    //}
}

-(void)setVMcountLabelHidden{
    
    NSString * count  = [[NSUserDefaults standardUserDefaults]objectForKey:@"VMcountLabelCount"];
    if ([count integerValue]==0) {
        _VMcountLabel.hidden = YES;
    }
    else
    {
        _VMcountLabel.hidden = NO;
        _VMcountLabel.text = count;
    }
}


#pragma mark -
#pragma mark viewDidLoad


-(void)viewDidAppear:(BOOL)animated {
    if (!allnumbers || allnumbers.count == 0) {
        [contactView initAllContacts];
        /*
         NSMutableArray *mutArr = [NSMutableArray arrayWithArray:[contactView allNumbers]];
         NSArray *historyArray = [recentView getHistorys];
         for (History *history in historyArray) {
         [mutArr addObject:history.mRemoteParty];
         }
         
         NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
         for (NSString *item in mutArr) {
         [resultDic setObject:item forKey:item];//字典筛选
         }
         allnumbers = [NSMutableArray arrayWithArray:resultDic.allValues];
         */
    }
    [self traitCollectionDidChange:self.traitCollection];
    
}

-(void)setnumnum{
    
    NSString *purchText1 = self.num1.titleLabel.text;
    NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString:purchText1];
    
    NSRange foundRange1 = [purchText1 rangeOfString:@"aaa"];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",purchText1]];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Book" size:14.0] range:foundRange1];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:foundRange1];
    self.num1.titleLabel.attributedText = str;
    
    NSString *purchText2 = self.num2.titleLabel.text;
    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:purchText2];
    NSRange foundRange2 = [purchText2 rangeOfString:@"abc"];
    [attrString2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Book" size:14] range:foundRange2];
    self.num2.titleLabel.attributedText = attrString2;
    
    NSString *purchText3 = self.num3.titleLabel.text;
    NSMutableAttributedString *attrString3 = [[NSMutableAttributedString alloc] initWithString:purchText3];
    NSRange foundRange3 = [purchText3 rangeOfString:@"def"];
    [attrString3 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Book" size:14] range:foundRange3];
    self.num3.titleLabel.attributedText = attrString3;
    
    //num4
    NSString *purchText4 = self.num4.titleLabel.text;
    NSMutableAttributedString *attrString4 = [[NSMutableAttributedString alloc] initWithString:purchText4];
    NSRange foundRange4 = [purchText4 rangeOfString:@"ghi"];
    [attrString4 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Book" size:14] range:foundRange4];
    self.num4.titleLabel.attributedText = attrString4;
    
    //num5
    NSString *purchText5 = self.num5.titleLabel.text;
    NSMutableAttributedString *attrString5 = [[NSMutableAttributedString alloc] initWithString:purchText5];
    NSRange foundRange5 = [purchText5 rangeOfString:@"jkl"];
    [attrString5 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Book" size:14] range:foundRange5];
    self.num5.titleLabel.attributedText = attrString5;
    
    //num
    NSString *purchText6 = self.num6.titleLabel.text;
    NSMutableAttributedString *attrString6 = [[NSMutableAttributedString alloc] initWithString:purchText6];
    NSRange foundRange6 = [purchText6 rangeOfString:@"mno"];
    [attrString6 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Book" size:14] range:foundRange6];
    self.num6.titleLabel.attributedText = attrString6;
    
    //num7
    NSString *purchText7 = self.num7.titleLabel.text;
    NSMutableAttributedString *attrString7 = [[NSMutableAttributedString alloc] initWithString:purchText7];
    NSRange foundRange7 = [purchText7 rangeOfString:@"pqrs"];
    [attrString7 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Book" size:14] range:foundRange7];
    self.num7.titleLabel.attributedText = attrString7;
    
    //num8
    NSString *purchText8 = self.num8.titleLabel.text;
    NSMutableAttributedString *attrString8 = [[NSMutableAttributedString alloc] initWithString:purchText8];
    NSRange foundRange8 = [purchText8 rangeOfString:@"tuv"];
    [attrString8 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Book" size:14] range:foundRange8];
    self.num8.titleLabel.attributedText = attrString8;
    
    
    //num9
    NSString *purchText9 = self.num9.titleLabel.text;
    NSMutableAttributedString *attrString9 = [[NSMutableAttributedString alloc] initWithString:purchText9];
    NSRange foundRange9 = [purchText9 rangeOfString:@"wxyz"];
    [attrString9 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Book" size:14] range:foundRange9];
    self.num9.titleLabel.attributedText = attrString9;
    
    //num0
    NSString *purchText0 = self.num0.titleLabel.text;
    NSMutableAttributedString *attrString0 = [[NSMutableAttributedString alloc] initWithString:purchText0];
    NSRange foundRange0 = [purchText0 rangeOfString:@"+"];
    [attrString0 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Book" size:14] range:foundRange0];
    self.num0.titleLabel.attributedText = attrString0;
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setnumnum];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setVMcountLabelHidden) name:@"VMcountLabelCount" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onInviteStatus) name:@"InviteEvent" object:nil];
    
    _mAccount = shareAppDelegate.portSIPHandle.mAccount;
    
    [_audioCallButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-25);
        make.width.equalTo(@(80));
        make.height.equalTo(@(80));
    }];
    
    NSLog(@"height=====%f    width==%f",_audioCallButton.frame.size.height,_audioCallButton.frame.size.width);
    _audioCallButton.layer.cornerRadius = 40;
    _audioCallButton.layer.masksToBounds = YES;
    
    searchResult = [NSMutableArray array];
    _searchTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _searchTableview.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    
    //    [_transferButton setTitle:NSLocalizedString(@"Transfer", @"Transfer") forState:UIControlStateNormal];
    _numberTextField.delegate = self;
    
    [_balanceLabel setHidden:YES];
    [_accountInfoLabel setText:[portSIPEngine mAccount].accountName];
    
    
    [_accountInfoLabel setFont:[UIFont systemFontOfSize:19]];
    
    [_returnCallButton setTitle:NSLocalizedString(@"Tap to Return Call", @"Tap to Return Call") forState:UIControlStateNormal];
    
    _numberTextField.minimumFontSize = 14;
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer1 setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizer1];
    
    [portSIPEngine setVideoDeviceId:1];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTransferNotification:) name:OnTransfer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSessid:) name:@"setSessid" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegisterState:) name:REGISTER_STATE object:nil];
    
    [_numberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _numberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
#ifndef HAVE_VIDEO
    [_videoCallButton removeFromSuperview];
    [_audioCallButton setCenter:_transferButton.center];
#endif
    
    
    if (!_upArrowimageview) {
        _upArrowimageview = [[UIImageView alloc]init];
        [_upArrowimageview setImage:[UIImage imageNamed:@"dial_up_ico"]];
        [_bottomButton addSubview:_upArrowimageview];
        [_upArrowimageview mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_bottomButton.mas_centerX);
            make.centerY.equalTo(_bottomButton.mas_centerY);
            make.width.equalTo(@(17));
            make.height.equalTo(@(24));
        }];
    }
    
    
    _callforbutton   = [[UIButton alloc]init];
    [_callforbutton addTarget:self action:@selector(dtmf_transfer) forControlEvents:UIControlEventTouchUpInside];
    [_dtmfView addSubview:_callforbutton];
    [_callforbutton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_bottomButton.mas_centerX);
        make.top.equalTo(_dtmfView.mas_bottom).with.offset(-60);
        make.width.equalTo(@(126));
        make.height.equalTo(@(38));
    }];
    
    
    [_callforbutton setBackgroundImage:[UIImage imageNamed:@"button_bg.png"] forState:UIControlStateNormal];
    [_callforbutton setImage:[UIImage imageNamed:@"dtmf_transfer"] forState:UIControlStateNormal];
    _callforbutton.layer.cornerRadius = _audioCallButton.bounds.size.height / 2 - 5-5;
    _callforbutton.layer.masksToBounds = YES;
    _callforbutton.hidden = YES;
    
    
    
    //VM小红点初始化
    _VMcountLabel = [[UILabel alloc]init];
    _VMcountLabel.backgroundColor = [UIColor redColor];
    _VMcountLabel.textAlignment = NSTextAlignmentCenter;
    _VMcountLabel.font = [UIFont systemFontOfSize:11];
    
    NSString *VMcountLabelCount = [[NSUserDefaults standardUserDefaults]objectForKey:@"VMcountLabelCount"];
    _VMcountLabel.text =VMcountLabelCount;
    _VMcountLabel.textColor =[UIColor whiteColor];
    
    [_transferButton addSubview:_VMcountLabel];
    [self setVMcountLabelHidden];
    [_VMcountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_transferButton.mas_top).with.offset(10);
        make.right.equalTo(_transferButton.mas_right).with.offset(-10);
        make.width.equalTo(@(16));
        make.height.equalTo(@(16));
    }];
    
    _VMcountLabel.layer.cornerRadius = 8;
    _VMcountLabel.clipsToBounds = YES;
    
    _ScanQRButton.hidden = TRUE;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [super setNeedsStatusBarAppearanceUpdate];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self refreshReturnButtonState];
    [self getBalance];
    
    _callfowardbutton .hidden = YES;
    _nodisturbebutton.hidden = YES;
    
    
    NSString * callforwardindex = [[NSUserDefaults standardUserDefaults]objectForKey:@"callforwardindex"];
    if ([callforwardindex isEqualToString:@"0"] ||  callforwardindex ==nil ) {
        _callfowardbutton .hidden = YES;
    }
    else
    {
        _callfowardbutton .hidden = NO;
    }
    
    
    BOOL setDoNotDisturb = [[NSUserDefaults standardUserDefaults]boolForKey:@"setDoNotDisturb"];
    if (setDoNotDisturb) {
        _nodisturbebutton.hidden = NO;
    }
    
    if  (![callforwardindex isEqualToString:@"0"] && setDoNotDisturb ){
        _callfowardbutton .hidden = YES;
        _nodisturbebutton.hidden = NO;
        _nodisturbebutton.frame = _callfowardbutton.frame;
    }
    
    if  (_nodisturbebutton.hidden == NO && _callfowardbutton.hidden == YES){
        _nodisturbebutton.frame = _callfowardbutton.frame;
    }
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognize {
    if (recognize.direction == UISwipeGestureRecognizerDirectionDown) {
        
    } else if (recognize.direction == UISwipeGestureRecognizerDirectionUp) {
        
    }
}


#pragma mark -onRegisterState 拨号界面在线状态
- (void)onRegisterState:(NSNotification*)sender
{
    NSString *state = [sender object];
    
    [[NSUserDefaults standardUserDefaults]setObject:state forKey:@"REGISTER_STATE_state"];// 提供给设置界面判断在线状态
    
    if ([state isEqualToString:REGISTER_STATE_SUCCESS]) {
        [_indicator stopAnimating];
        [_indicator removeFromSuperview];
        [self setAccountState:@""];
        _accountInfoLabel.textColor = [UIColor whiteColor];
        
    }
    else if ([state isEqualToString:REGISTER_STATE_REGISTERING]){
        if (!_indicator) {
            _indicator = [[UIActivityIndicatorView alloc] init];
            //[_indicator setFrame:CGRectMake(_accountInfoLabel.bounds.size.width / 2 - 10, 0, 20, 20)];
            [_indicator setFrame:CGRectMake(_accountInfoLabel.bounds.size.width , 0, 20, 20)];
        }
        [_accountInfoLabel addSubview:_indicator];
        [_indicator startAnimating];
        /*
         [self setAccountState:[NSString stringWithFormat:@"(%@)", NSLocalizedString(@"offline", @"offline")]];
         _accountInfoLabel.textColor = [UIColor redColor];*/
    }
    else{
        [_indicator stopAnimating];
        [_indicator removeFromSuperview];
        [self setAccountState:[NSString stringWithFormat:@"(%@)", NSLocalizedString(@"offline", @"offline")]];
        _accountInfoLabel.textColor = [UIColor redColor];
    }
    
}

- (void)setAccountState:(NSString *)state
{
    _accountInfoLabel.text = [NSString stringWithFormat:@"%@%@", [portSIPEngine mAccount].accountName, state];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - onTransferNotification

-(void)dtmf_transfer{
    
    if (_numberTextField.text > 0) {
        
        [portSIPEngine refer:_mSessionId referTo:_numberTextField.text];
        _transferButton.tag = 100;
        _videoCallButton.hidden = NO;
        _audioCallButton.hidden = NO;
        
        HSSession * session = [shareAppDelegate.callManager findCallBySessionID:_mSessionId];
        if(session!=nil){
            [shareAppDelegate onBackCall:session.uuid];
        }else{
            [shareAppDelegate onBackCall:nil];
        }
    }
    _numberTextField.text = @"";
    [self textFieldChanged:nil];
    
    
}

- (void)onTransferNotification:(NSNotification*)notification
{
    
    int  notifincationValue =  [[notification object] intValue];
    
    NSLog(@"_mSessionId= notifincationValue= %d ",notifincationValue);
    
    if (notifincationValue == 8) {
        
        _numberTextField.text = @"";
        [self textFieldChanged:nil];
        [_transferButton setImage:[UIImage imageNamed:@"dial_voicemail"] forState:UIControlStateNormal];
        _videoCallButton.hidden = NO;
        _audioCallButton.hidden = NO;
        _transferButton.hidden = NO;
        _transferButton.tag = 100;
        _callforbutton.hidden  = YES;
        
    }else if (notifincationValue == -1) {
        _transferButton.tag = 101;
        _numberTextField.text = @"";
        [self textFieldChanged:nil];
        [_transferButton setImage:[UIImage imageNamed:@"dtmf_transfer.png"] forState:UIControlStateNormal];
        _videoCallButton.hidden = YES;
        _audioCallButton.hidden = YES;
        
        _transferButton.hidden =YES;
        _callforbutton.hidden = NO;
    }else{
        _transferButton.tag = 100;
        _numberTextField.text = @"";
        [self textFieldChanged:nil];
        [_transferButton setImage:[UIImage imageNamed:@"dial_voicemail"] forState:UIControlStateNormal];
        _videoCallButton.hidden = NO;
        _audioCallButton.hidden = NO;
        _transferButton.hidden = YES;
        
        _callforbutton .hidden = YES;
        
    }
}


- (void)getBalance
{
}

-(void)ReceiveDataFinish:(NSString*)srtData
{
    MLLog(@"ReceiveDataFinish");
}
-(void)ReceiveBalance:(NSString*)balanceValue
{
    if (![balanceValue hasPrefix:@"$"]) {
        _balanceLabel.text = [NSString stringWithFormat:@"$%@", balanceValue];
    }
    else{
        _balanceLabel.text = [NSString stringWithFormat:@"%@", balanceValue];
    }
    MLLog(@"ReceiveBalance %@", balanceValue);
}
-(void)ReceiveCreditTime:(NSString*)numberType CreditTime:(NSString*)creditTimeValue
{
    MLLog(@"ReceiveCreditTime");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return !_returnCallButton.hidden;
}

- (void)refreshReturnButtonState
{
    
    if ([shareAppDelegate.callManager getConnectCallNum]) {
        _returnCallButton.hidden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }else{
        _returnCallButton.hidden = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
}

#pragma mark - KeypadTransparentButtonClicked
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRegisterSuccess:(int)statusCode withStatusText:(char*) statusText
{
}

- (void)onRegisterFailure:(int)statusCode withStatusText:(char*) statusText
{
}

- (IBAction)onReturnButtonClick:(id)sender {
    HSSession * session = [shareAppDelegate.callManager findCallBySessionID:_mSessionId];
    if(session!=nil){
        [shareAppDelegate onBackCall:session.uuid];
    }else{
        [shareAppDelegate onBackCall:nil];
    }
}

- (IBAction)addToAddressBook:(id)sender {
    
    AddorEditViewController *ctr = [[AddorEditViewController alloc] init];
    ctr.modalPresentationStyle = UIModalPresentationFullScreen;
    ctr.recognizeID = 2444;
    ctr.numbPadenterString = _numberTextField.text;
    
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:ctr];
    navc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navc animated:YES completion:^{
        
    }];
}

- (IBAction)onDelButtonPressDown:(id)sender {
    long letterLength;
    letterLength = _numberTextField.text.length - 1;
    _numberTextField.text = [_numberTextField.text substringToIndex:letterLength > 0 ? letterLength : 0];
    [self textFieldChanged:nil];
    [self performSelector:@selector(onLongClick:) withObject:sender afterDelay:0.8];
    
}

-(void) onLongClick:(UIButton*)sender{
    _numberTextField.text = @"";
    [self textFieldChanged:nil];
}

- (IBAction)onDelButtonUp:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onLongClick:) object:sender];
}

- (IBAction)onNumericalButtonClick:(id)sender {
    
    [_numberTextField resignFirstResponder];
    
    NSInteger tag = ((UIButton*)sender).tag;
    NSString *letter = nil;
    
    if (tag == kTAGStar) {
        letter = @"*";
    }
    else if (tag == kTAGSharp) {
        letter = @"#";
    }
    else{
        letter = [NSString stringWithFormat:@"%ld", (long)tag];
    }
    
    if (_numberTextField.text == nil) {
        _numberTextField.text = letter;
    }
    else{
        _numberTextField.text = [_numberTextField.text stringByAppendingString:letter];
    }
    [self textFieldChanged:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [soundServiceEngine playDtmf:(int)tag];
    });
    
}

- (IBAction)onVideoButtonClick:(id)sender {
    
    NSString * numstr =_numberTextField.text;
    NSString* FrontPart;
    NSString* behindPart;
    NSString * tempstr ;
    NSMutableArray *personarr = [[DataBase sharedDataBase]getAllPerson];
    
    for (Person *person in personarr ) {
        
        NSString * str1 = person.str1;
        
        if ([person.str1 isEqualToString:@""]) {
            
            if ([person.str2 isEqualToString:@""]) {
                tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
            }
            else
            {
                if (numstr.length >person.str2.length) {
                    
                    FrontPart = [numstr substringToIndex:person.str2.length];
                    behindPart = [numstr substringFromIndex:person.str2.length];
                    
                    if ([FrontPart rangeOfString:person.str2].location != NSNotFound){
                        tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,behindPart];
                    }
                    else
                    {
                        tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
                    }
                    
                }
                else
                {
                    tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
                }
            }
            
            break;
            
        }
        
        if ([numstr rangeOfString:str1].location != NSNotFound) {
            
            if ([person.str2 isEqualToString:@""]) {
                tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
            }
            else{
                if (numstr.length >= person.str2.length) {
                    
                    FrontPart = [numstr substringToIndex:person.str2.length];
                    behindPart = [numstr substringFromIndex:person.str2.length];
                    
                    if ([FrontPart rangeOfString:person.str2].location != NSNotFound){
                        tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,behindPart];
                    }
                    else
                    {
                        tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
                    }
                }
                else
                {
                    
                    tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
                }
            }
            break;
            
        }
        
    }
    
    if ([tempstr isEqualToString:@""] || [tempstr isEqual:[NSNull null]] || tempstr==nil) {
        
        tempstr = _numberTextField.text;
    }
    
    NSString *phoneNum = tempstr;
    
    
    if (phoneNum.length > 0 ) {
        [shareAppDelegate makeCall:phoneNum videoCall:YES];
        _numberTextField.text = @"";
    }else{
        NSMutableArray *historyArray = [databaseManage selectHistory:0 byMediaType:MediaType_AudioVideo LocalUri:AppDelegate.sharedInstance.account.userName orderBYDESC:YES needCount:NO];
        if(historyArray.count>0){
            History* history = historyArray.firstObject;
            _numberTextField.text =  [history.mRemoteParty getUriUsername:history.mRemoteParty];
        }
    }
    
    [self textFieldChanged:nil];
}

#pragma  mark--
#pragma mark
- (IBAction)onAudioButtonClick:(id)sender {
    NSString * numstr =_numberTextField.text;
    
    NSString* FrontPart;
    
    NSString* behindPart;
    
    
    NSString * tempstr ;
    
    NSMutableArray *personarr = [[DataBase sharedDataBase]getAllPerson];
    
    for (Person *person in personarr ) {
        
        NSString * str1 = person.str1;
        
        if ([person.str1 isEqualToString:@""]) {
            
            if ([person.str2 isEqualToString:@""]) {
                tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
            }
            else
            {
                if (numstr.length >person.str2.length) {
                    FrontPart = [numstr substringToIndex:person.str2.length];
                    behindPart = [numstr substringFromIndex:person.str2.length];
                    
                    
                    if ([FrontPart rangeOfString:person.str2].location != NSNotFound){
                        tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,behindPart];
                    }
                    else
                    {
                        tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
                    }
                    
                }
                else
                {
                    tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
                }
                
            }
            
            break;
            
        }
        
        if ([numstr rangeOfString:str1].location != NSNotFound) {
            
            if ([person.str2 isEqualToString:@""]) {
                tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
            }
            else{
                
                if (numstr.length >= person.str2.length) {
                    
                    FrontPart = [numstr substringToIndex:person.str2.length];
                    
                    behindPart = [numstr substringFromIndex:person.str2.length];
                    
                    if ([FrontPart rangeOfString:person.str2].location != NSNotFound){
                        tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,behindPart];
                    }
                    else
                    {
                        tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
                    }
                    
                }
                else
                {
                    tempstr  = [NSString stringWithFormat:@"%@%@",person.str3,numstr];
                }
            }
            break;
            
        }
        
    }
    
    if ([tempstr isEqualToString:@""] || [tempstr isEqual:[NSNull null]] || tempstr==nil) {
        
        tempstr = _numberTextField.text;
    }
    
    NSString *phoneNum = tempstr;
    
    
    if (phoneNum.length > 0 ) {
        
        [shareAppDelegate makeCall:phoneNum videoCall:NO];
        _numberTextField.text = @"";
    }else{
        NSMutableArray *historyArray = [databaseManage selectHistory:0 byMediaType:MediaType_AudioVideo LocalUri:AppDelegate.sharedInstance.account.userName orderBYDESC:YES needCount:NO];
        if(historyArray.count>0){
            History* history = historyArray.firstObject;
            _numberTextField.text = [history.mRemoteParty getUriUsername:history.mRemoteParty];
        }
    }
    
    [self textFieldChanged:nil];
}

- (IBAction)onTransferButtonClick:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 100) {
        NSString *voicemail = _mAccount.voiceMail;
        
        if (voicemail.length > 0) {
            [shareAppDelegate makeCall:voicemail videoCall:NO];
            [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"VMcountLabelCount"];
            [self setVMcountLabelHidden];
        }
        else
        {
            [self.view makeToast:NSLocalizedString(@"You have no Voice Mail number!", @"You have no Voice Mail number!") duration:1.0 position:@"center"];
        }
        
    } else {
        if (_numberTextField.text > 0) {
            [portSIPEngine refer:_mSessionId referTo:_numberTextField.text];
            _transferButton.tag = 100;
            _videoCallButton.hidden = NO;
            _audioCallButton.hidden = NO;
            HSSession * session = [shareAppDelegate.callManager findCallBySessionID:_mSessionId];
            if(session!=nil){
                [shareAppDelegate onBackCall:session.uuid];
            }else{
                [shareAppDelegate onBackCall:nil];
            }
        }
        _numberTextField.text = @"";
        [self textFieldChanged:nil];
    }
}

- (IBAction)bottomClick:(id)sender {
    _dtmfView.hidden = NO;
    _bottomButton.hidden = YES;
}

#pragma mark - TableVIewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchResult.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 32;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifi = @"searchCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifi];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifi];
    
    cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    if (searchResult.count > indexPath.row) {
        NSArray *item = searchResult[indexPath.row];
        NSString* displayName = item[0];
        NSString* number =item[1];
        if(displayName && displayName.length > 0)
        {
            cell.textLabel.text = displayName;
            
            NSRange  rangemata = [cell.textLabel.text rangeOfString:_numberTextField.text];
            NSString *content =cell.textLabel.text;
            
            NSMutableAttributedString *attributeString  = [[NSMutableAttributedString alloc]initWithString:content];
            [attributeString setAttributes:@{NSForegroundColorAttributeName:RGB(75, 194, 255),NSFontAttributeName:[UIFont systemFontOfSize:17.f]} range:rangemata];
            
            
            cell.textLabel.attributedText =attributeString;
        }
        
        numberlab = [[UILabel alloc]init];
        numberlab.frame = CGRectMake(MAIN_SCREEN_WIDTH-170, 0, 160, 32);
        numberlab.font = [UIFont systemFontOfSize:12];
        numberlab.textAlignment=  NSTextAlignmentRight;
        numberlab.text = number;
        
        [cell.contentView addSubview:numberlab];
        
        NSString *content2 = numberlab.text;
        NSRange  rangemata = [numberlab.text rangeOfString:_numberTextField.text];
        NSMutableAttributedString *attributeString2  = [[NSMutableAttributedString alloc]initWithString:content2];
        
        [attributeString2 setAttributes:@{NSForegroundColorAttributeName:RGB(75, 194, 255),NSFontAttributeName:[UIFont systemFontOfSize:12.f]} range:NSMakeRange(rangemata.location, rangemata.length)];
        
        
        numberlab.attributedText = attributeString2;
        
        return cell;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (searchResult.count > indexPath.row) {
        NSArray *item = searchResult[indexPath.row];
        //        NSString* displayName = item[0];
        NSString* number =item[1];
        
        _numberTextField.text = number;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark ABPeoplePickerNavigationController

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [_picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (property != kABPersonPhoneProperty && property != kABPersonEmailProperty && property != kABPersonSocialProfileProperty) {
        return;
    }
    
    ABMutableMultiValueRef phontMultif = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(phontMultif, identifier);
    
    
    if (property == kABPersonSocialProfileProperty) {
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:(__bridge NSDictionary * _Nonnull)(ABMultiValueCopyValueAtIndex(phontMultif, index))];
        NSString *key = [dic allKeys][0];
        
        [_picker dismissViewControllerAnimated:YES completion:nil];
        _numberTextField.text = dic[key];
        [self textFieldChanged:nil];
        
    } else if (property == kABPersonPhoneProperty) {
        NSString *aPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phontMultif, index);
        
        [_picker dismissViewControllerAnimated:YES completion:nil];
        
        _numberTextField.text = aPhone;
        [self textFieldChanged:nil];
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (property != kABPersonPhoneProperty && property != kABPersonEmailProperty && property != kABPersonSocialProfileProperty) {
        return YES;
    }
    
    ABMutableMultiValueRef phontMultif = ABRecordCopyValue(person, property);
    
    if (property == kABPersonPhoneProperty) {
        NSString *aPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phontMultif, identifier);
        
        [_picker dismissViewControllerAnimated:YES completion:nil];
        
        _numberTextField.text = aPhone;
        [self textFieldChanged:nil];
    }
    
    else if (property == kABPersonSocialProfileProperty) {
        NSDictionary *dic = (__bridge NSDictionary *)(ABMultiValueCopyValueAtIndex(phontMultif, identifier));
        NSString *key = [dic allKeys][0];
        
        [_picker dismissViewControllerAnimated:YES completion:nil];
        _numberTextField.text = dic[key];
        [self textFieldChanged:nil];
    }
    return NO;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bkColor = [UIColor colorWithHexString:@"#f4f3f3"];
    }
    
    [self.tabBarController.tabBar setBarTintColor:bkColor];
}

- (void)pickPerson:(BOOL)animated {
    
    _picker = [[ABPeoplePickerNavigationController alloc] init];
    
    [_picker.topViewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tabbar_background.png"] forBarMetrics:UIBarMetricsDefault];
    [_picker.topViewController.navigationController.navigationBar setTintColor:MAIN_COLOR];
    //[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : MAIN_COLOR}];
    [self.navigationController.navigationBar setTintColor:MAIN_COLOR];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:MAIN_COLOR}];
    
    
    
    // UIImage *colorImage = [UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)];
    
    
    [self.navigationController.navigationBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    [self.tabBarController.tabBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    [self.tabBarController.tabBar setBackgroundImage:[[UIImage alloc]init]];
    
    _picker.peoplePickerDelegate = self;
    _picker.displayedProperties = @[[NSNumber numberWithInt:kABPersonSocialProfileProperty],[NSNumber numberWithInt:kABPersonPhoneProperty]];
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        _picker.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
    }
    _picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:_picker animated:animated completion:nil];
}

-(void)updateFilteredContentForSearchString:(NSString *)searchString {
    
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    lastContentOffset = scrollView.contentOffset.y;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_dtmfView.isHidden || scrollView != _searchTableview) {
        return;
    }
    
    if (scrollView.contentOffset.y < lastContentOffset - 10) {
        _dtmfView.hidden = YES;
        _bottomButton.hidden = NO;
        
        
    }
}

#pragma mark -UITextFieldDelegate

-(void)textFieldDidChange :(UITextField *)theTextField{
    [self textFieldChanged:nil];
}


- (void)textFieldChanged:(id)sender
{
    NSLog( @"text changed: %@", _numberTextField.text);
    _numberTextField.text= [_numberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, _numberTextField.text.length)];
#ifdef INPUT_EMAIL_SIGN    //shi fou shuru @
    if  ([_numberTextField.text rangeOfString:@"@"].location !=NSNotFound){
        NSArray *strs = [_numberTextField.text componentsSeparatedByString:@"@"];
        _numberTextField.text = strs[0];
    }
#endif
    
    [_deleteButton setImage:[UIImage imageNamed:@"dial_del_number_ico"] forState:UIControlStateNormal];
    CGRect rect = _deleteButton.frame;
    rect.size.width = 30;
    rect.size.height = 30;
    [_deleteButton setFrame:rect];
    
    if (_numberTextField.text.length > 0) {
        //        _deleteButton.tag = 1;
        _deleteButton.hidden = NO;
    } else {
        _deleteButton.hidden = YES;
    }
    
    [searchResult removeAllObjects];
    
    NSMutableArray *tempArr = [NSMutableArray array];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSArray *contactArray = [contactView contacts];
    
    
    
    for (Contact* contact in contactArray)
    {
        if (contact)
        {
            BOOL isDisplayNameMatched = NO;
            
            if( contact.displayName &&
               [contact.displayName rangeOfString:_numberTextField.text  options:NSCaseInsensitiveSearch].location != NSNotFound)
            {//If dispaly name matched, add all number
                isDisplayNameMatched = YES;
            }
            
            if (contact.phoneNumbers.count > 0) {
                
                for(NgnPhoneNumber *phoneNumber in contact.phoneNumbers){
                    if(phoneNumber.number && (isDisplayNameMatched ||  [phoneNumber.number rangeOfString:_numberTextField.text  options:NSCaseInsensitiveSearch].location != NSNotFound)){
                        [tempArr addObject:[NSArray arrayWithObjects:contact.displayName,phoneNumber.number,nil]];
                    }
                }
            }
            
            if(contact.IPCallNumbers.count > 0) {
                for (NSDictionary *IPCall in contact.IPCallNumbers) {
                    NSString *key = [IPCall allKeys][0];
                    NSString *value = [IPCall objectForKey:key];
                    if(value && (isDisplayNameMatched ||  [value rangeOfString:_numberTextField.text  options:NSCaseInsensitiveSearch].location != NSNotFound)){
                        [tempArr addObject:[NSArray arrayWithObjects:contact.displayName,value,nil]];
                    }
                }
            }
        }
    }
    
    for (NSArray *values in tempArr) {
        if (values[0]) {
            NSString *displayname = values[0];
            [dic setObject:values forKey:displayname];
        }
    }
    [searchResult addObjectsFromArray:[dic allValues]];
    
    
    NSSet *set = [NSSet setWithArray:tempArr];
    
    searchResult = [[NSMutableArray alloc]initWithArray:[set allObjects]];
    
    [self.searchTableview reloadData];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_numberTextField resignFirstResponder];
    return YES;
}
- (IBAction)nodisture:(id)sender {
    
    NSLog(@"nodisture");
    
    [self.tabBarController setSelectedIndex:4];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"showNodistrbe" object:@"0"];
    
}
- (IBAction)callforward:(id)sender {
    
    [self.tabBarController setSelectedIndex:4];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"showNodistrbe" object:@"1"];
    
}
- (IBAction)ScanQR:(id)sender {
    ScanQRViewController* scancon  = [[ScanQRViewController alloc]init];
    [self presentViewController:scancon animated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return 1;
}

-(void)setSessid:(NSNotification*)idstr{
    _mSessionId = [[idstr object] intValue];
}

@end
