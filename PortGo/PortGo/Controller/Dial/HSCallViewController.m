//
//  HSCallViewController.m
//  PortGo
//
//  Created by MrLee on 14-9-23.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSCallViewController.h"
#import "UIImage+HSImage.h"
#import "AppDelegate.h"
#import "Options.h"
#import "HSSession.h"
#import "NSString+HSFilterString.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "TextImageView.h"
#import "DataBase.h"
#import "Masonry.h"

@interface HSCallViewController ()<UIScrollViewDelegate, UIActionSheetDelegate>
{
    UIView *_circleScale;
    CALayer *_circleRotate;
    
    TextImageView *_callTextImage;
    TextImageView *_logoTextImage;
    
    NSUUID *_sessionId;
    
    
    //NSDate *_beginTime;
    NSTimer *_beginTimeTimer;
    
    History *_history;
    
    NSUInteger _mCurrentCallingCount;
    NSUInteger _mCameraDeviceId;
    
    UIInterfaceOrientation _mLastOrientation;
    UIInterfaceOrientation _mCurrentOrientation;
    
    BOOL handleNotif;
    BOOL _hasBlueTooth;
    BOOL _speakerState;
    BOOL _reocrdImageShowed;
    BOOL _hasVideo;
    BOOL _earlyMedia;
    BOOL _isCallBuildSuccess;
    BOOL _mIsLandscape;
    BOOL isLandscape3;
    BOOL  isfirtcomeon;
    BOOL  isspeaker;
    
    int mRemoteVideoHeight;
    int mRemoteVideoWidth;
    
    CGFloat  tempwidth;
    CGFloat  tempheight;
    CGPoint _lastLocation;
    
    NSTimer * hiddenTimer;
    NSTimer* _recordTimer;
}

@property (nonatomic, assign) BOOL speakerState;

@property (weak, nonatomic) IBOutlet UIButton *hiddenButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *remoteLabel;
@property (weak, nonatomic) IBOutlet UIButton *microButton1;
@property (weak, nonatomic) IBOutlet UIButton *loudSpeaker1;
@property (weak, nonatomic) IBOutlet UILabel *callingStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *hungupButton;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UILabel *callNameLabel;

@property (strong, nonatomic) IBOutlet UIView *callView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLongLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;
@property (weak, nonatomic) IBOutlet UIButton *hungupButton2;

@property (strong, nonatomic) IBOutlet UIView *dtmfView;
@property (weak, nonatomic) IBOutlet UIView *dtmfBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *dtmfDisplayLabel;

@property (strong, nonatomic) IBOutlet UIView *scrollViewPageOne;
@property (strong, nonatomic) IBOutlet UIView *scrollViewPageTwo;
@property (weak, nonatomic) IBOutlet UIView *scrollBottomView;

@property (weak, nonatomic) IBOutlet UIButton *scrollVideoButton;
@property (strong, nonatomic) IBOutlet UIView *cameraOptionView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraOptionImageView;
@property (weak, nonatomic) IBOutlet UIButton *scrollOnOffCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *scrollFrontBackButton;
@property (weak, nonatomic) IBOutlet UIImageView *cameraOptionArrow;
@property (weak, nonatomic) IBOutlet UIButton *scrollMicoButton;
@property (weak, nonatomic) IBOutlet UIButton *scrollLoudlyButton;
@property (weak, nonatomic) IBOutlet UIButton *scrollDtmfButton;
@property (weak, nonatomic) IBOutlet UIButton *scrollHoldButton;
@property (weak, nonatomic) IBOutlet UIButton *scrollAddButton;
@property (weak, nonatomic) IBOutlet UIButton *scrollAudioButton;
@property (weak, nonatomic) IBOutlet UIButton *scrollRecordButton;

@property (strong, nonatomic) IBOutlet PortSIPVideoRenderView *localVideoView;
@property (strong, nonatomic) IBOutlet PortSIPVideoRenderView *remoteVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *remoteBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *recordImageView;
@property (weak, nonatomic) IBOutlet UILabel *costRate;

@property (weak, nonatomic) IBOutlet UIButton *frontCamera;
@property (weak, nonatomic) IBOutlet UIButton *backCamera;
@property (weak, nonatomic) IBOutlet UIButton *noneCamera;
//Dual Line
@property (weak, nonatomic) IBOutlet UIView *lineOneView;
@property (weak, nonatomic) IBOutlet UILabel *lineOneDisplayName;
@property (weak, nonatomic) IBOutlet UILabel *lineOneLabel;
@property (weak, nonatomic) IBOutlet UIButton *lineOneButton;

@property (weak, nonatomic) IBOutlet UIView *lineTwoView;
@property (weak, nonatomic) IBOutlet UILabel *lineTwoDisplayName;
@property (weak, nonatomic) IBOutlet UILabel *lineTwoLabel;
@property (weak, nonatomic) IBOutlet UIButton *lineTwoButton;
@property (weak, nonatomic) IBOutlet UIView *callandhunupview;
@property (weak, nonatomic) IBOutlet UIButton *hiddenDtmfButton;

@end

@implementation HSCallViewController

#ifdef OEM_FIXEDHOST
-(void) getCreditTime
{
    if([portSIPEngine SIPInitialized])
    {
        URLAsyncGet* urlGet = [URLAsyncGet alloc];
        [urlGet getCreditTime:[portSIPEngine mAccount].userName
                     password:[portSIPEngine mAccount].password
                       callto:[_remotePartyName stringWithFilterPhoneNumber:_remotePartyName] delegate:self];
    }
}

-(void)ReceiveCreditTime:(NSString*)numberType CreditTime:(NSString*)creditTimeValue
{
    if (_callState == CALL_STATE_INCOMING) {
        return;
    }
    _costRate.text = [NSString stringWithFormat:@"%@  cost:%@",
                      numberType,
                      creditTimeValue];
}
#endif//OEM_FIXEDHOST

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isCallBuildSuccess = NO;
    }
    return self;
}

- (void)setRoundCornerButton:(UIButton*)btn radius:(CGFloat)radius
{
    btn.layer.cornerRadius = radius;
    btn.clipsToBounds = YES;
}

- (void)setCallButtonRoundCorner
{
    [self setRoundCornerButton:_hungupButton radius:_hungupButton.bounds.size.width / 2];
    [self setRoundCornerButton:_audioButton radius:_audioButton.bounds.size.width / 2];
    [self setRoundCornerButton:_videoButton radius:_videoButton.bounds.size.width / 2];
    [self setRoundCornerButton:_hungupButton2 radius:_hungupButton2.bounds.size.height / 2];
    //    [self setRoundCornerButton:_landscapeHangupButton radius:12];
}

- (void)setScrollButtonRoundCorner
{
    [self setRoundCornerButton:_scrollVideoButton radius:_scrollAddButton.bounds.size.width / 2];
    [self setRoundCornerButton:_scrollMicoButton radius:_scrollMicoButton.bounds.size.width / 2];
    [self setRoundCornerButton:_scrollLoudlyButton radius:_scrollLoudlyButton.bounds.size.width / 2];
    [self setRoundCornerButton:_scrollDtmfButton radius:_scrollDtmfButton.bounds.size.width / 2];
    [self setRoundCornerButton:_scrollHoldButton radius:_scrollHoldButton.bounds.size.width / 2];
    [self setRoundCornerButton:_scrollAddButton radius:_scrollAddButton.bounds.size.width / 2];
    [self setRoundCornerButton:_scrollAudioButton radius:_scrollAudioButton.bounds.size.width / 2];
    [self setRoundCornerButton:_scrollRecordButton radius:_scrollRecordButton.bounds.size.width / 2];
}

- (void)adjustButtonState
{
    if (_callType == HSCallTypeOutCallAudio || _callType == HSCallTypeOutCallVideo) {
        _audioButton.hidden = YES;
        _videoButton.hidden = YES;
        _microButton1.hidden = NO;
        _loudSpeaker1.hidden = NO;
        CGRect rect = _hungupButton.frame;
        
        rect.origin.x = MAIN_SCREEN_WIDTH / 2 - rect.size.width / 2;
        [_hungupButton setFrame:rect];
    }
    else if (_callType == HSCallTypeInCallAudio){
        _videoButton.hidden = YES;
        _microButton1.hidden = YES;
        _loudSpeaker1.hidden = YES;
        CGRect rect = _hungupButton.frame;
        
        
        CGFloat halfWidth = MAIN_SCREEN_WIDTH / 2;
        
        rect.origin.x = (halfWidth - 45) / 2 - 20;
        
        
        [_hungupButton setFrame:rect];
        
        rect.origin.x =  ScreenWid - ((halfWidth - 45) / 2 - 20) - rect.size.width;
        [_audioButton setFrame:rect];
        
    }
    else if (_callType == HSCallTypeInCallVideo){
        _microButton1.hidden = YES;
        _loudSpeaker1.hidden = YES;
    }
    
    [self refreshAppereance];
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setLineInfo
{
    if ([shareAppDelegate.callManager getConnectCallNum] == 2) {
        _lineOneView.hidden = NO;
        _lineTwoView.hidden = NO;
        
        HSSession*session = [shareAppDelegate.callManager findCallByIndex:0];
        if(session!=nil){
            
            _lineOneDisplayName.text = session.callViewController.remoteDisplayName;
            
            _lineOneLabel.text = session.callViewController.duration;
        }
        HSSession*sessionOther = [shareAppDelegate.callManager findCallByIndex:1];
        _lineTwoDisplayName.text = sessionOther.callViewController.remoteDisplayName;
        
        _lineTwoLabel.text = sessionOther.callViewController.duration;
        
        if ([session.uuid.UUIDString isEqualToString:_sessionId.UUIDString]) {
            _lineOneButton.enabled = NO;
            _lineTwoButton.enabled = YES;
            
            _lineOneDisplayName.textColor = [UIColor whiteColor];
            _lineOneLabel.textColor = [UIColor whiteColor];
            
            _lineTwoDisplayName.textColor = [UIColor darkGrayColor];
            _lineTwoLabel.textColor = [UIColor darkGrayColor];
        }
        else{
            _lineOneButton.enabled = YES;
            _lineTwoButton.enabled = NO;
            
            _lineOneDisplayName.textColor = [UIColor darkGrayColor];
            
            _lineOneLabel.textColor = [UIColor darkGrayColor];
            _lineTwoDisplayName.textColor = [UIColor whiteColor];
            _lineTwoLabel.textColor = [UIColor whiteColor];
        }
        
        if (_mIsConference) {
            _lineOneButton.enabled = NO;
            _lineTwoButton.enabled = NO;
            
            _lineOneDisplayName.textColor = [UIColor whiteColor];
            _lineOneLabel.textColor = [UIColor whiteColor];
            
            _lineTwoDisplayName.textColor = [UIColor whiteColor];
            _lineTwoLabel.textColor = [UIColor whiteColor];
        }
    }
}

- (IBAction)switchLineButtonClick:(id)sender {
    shareAppDelegate.numpadViewController.returnCallButton.alpha = 0;
    [self dismissViewControllerAnimated:NO completion:^{
        HSSession *session = [shareAppDelegate.callManager findCallByUUID:_sessionId];
        [shareAppDelegate switchLineFrom:session.sessionId];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_circleScale removeFromSuperview];
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
}

- (PortSIPVideoRenderView *)callRemoteVideoView
{
    return _remoteVideoView;
}

- (PortSIPVideoRenderView *)callLocalVideoView
{
    return _localVideoView;
}

- (void)addViewFadeAnimation
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.6f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionFade;
    
    [self.view.layer addAnimation:transition forKey:nil];
}

- (BOOL)includeChinese:(NSString *)predicateStr
{
    for(int i=0; i< [predicateStr length];i++)
    {
        int a =[predicateStr characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

-(void)createCallTextImage {
    CGRect getFrame = _remoteBgImageView.frame;
    _callTextImage = [[TextImageView alloc] initWithFrame:getFrame];
    
    if ([self includeChinese:_remoteDisplayName]) {
        NSString *substing = nil;
        if (_remoteDisplayName.length >= 2) {
            substing = [_remoteDisplayName substringToIndex:2];
        } else {
            substing = [_remoteDisplayName substringToIndex:1];
        }
        
        if ([self includeChinese:substing]) {
            _callTextImage.textImageLabel.text = [_remoteDisplayName substringToIndex:1];
        }
    } else {
        if (_remoteDisplayName.length >= 2) {
            
            NSString * tempstr = [_remoteDisplayName substringFromIndex:_remoteDisplayName.length-1];
            
            if ([_remoteDisplayName containsString:@" "] &&  ![tempstr isEqualToString:@" "]) {
                NSArray *strs = [_remoteDisplayName componentsSeparatedByString:@" "];
                NSString *first = strs[0];
                NSString *last = strs[1];
                
                
                if (first.length >=1 &&  last.length >=1) {
                    
                    
                    _callTextImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],[last substringToIndex:1]];
                }
                else
                {
                    
                    if (first.length<1  && last.length>=1) {
                        
                        _callTextImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",@"",[last substringToIndex:1]];
                    }
                    if (last.length<1 && first.length >=1) {
                        
                        _callTextImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],@""];
                    }
                    
                }
                
            } else {
                if (_remoteDisplayName.length >=2) {
                    
                    _callTextImage.textImageLabel.text = [_remoteDisplayName substringToIndex:2];
                }
            }
        } else {
            if (_remoteDisplayName.length == 0) {
                
                if (_remotePartyName.length >=2) {
                    _callTextImage.string = [_remotePartyName substringToIndex:2];
                }
            } else {
                
                if (_remoteDisplayName.length >=1) {
                    _callTextImage.string = [_remoteDisplayName substringToIndex:1];
                }
                
            }
        }
    }
    
    _callTextImage.textImageLabel.font = [UIFont fontWithName:@"Arial" size:50];
    _callTextImage.raduis = 60.0;
    _callTextImage.layer.borderWidth = 0.1;
    _callTextImage.layer.cornerRadius = _callTextImage.bounds.size.width / 2;
    _callTextImage.clipsToBounds = YES;
    [_callView addSubview:_callTextImage];
    
    
    
    [_callTextImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(_callView.mas_centerX);
        make.top.equalTo(_callView.mas_top).with.offset(120);
        make.width.equalTo(@(130));
        make.height.equalTo(@(130));
    }];
    
    CGRect getlogoFrame = _logoImageView.frame;
    _logoTextImage = [[TextImageView alloc] initWithFrame:getlogoFrame];
    
    
    if ([self includeChinese:_remoteDisplayName]) {
        NSString *substing = nil;
        if (_remoteDisplayName.length >= 2) {
            substing = [_remoteDisplayName substringToIndex:2];
        } else {
            substing = [_remoteDisplayName substringToIndex:1];
        }
        if ([self includeChinese:substing]) {
            _logoTextImage.textImageLabel.text = [_remoteDisplayName substringToIndex:1];
        }
    } else {
        if (_remoteDisplayName.length >= 2) {
            
            NSString * tempstr = [_remoteDisplayName substringFromIndex:_remoteDisplayName.length-1];
            
            if ([_remoteDisplayName containsString:@" "] &&  ![tempstr isEqualToString:@" "]) {
                NSArray *strs = [_remoteDisplayName componentsSeparatedByString:@" "];
                NSString *first = strs[0];
                NSString *last = strs[1];
                
                if (first.length<1) {
                    
                    first =@" ";
                }
                
                if (last.length <1) {
                    
                    last = @" ";
                }
                
                _logoTextImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],[last substringToIndex:1]];
                
                
            } else {
                _logoTextImage.textImageLabel.text = [_remoteDisplayName substringToIndex:2];
            }
        } else {
            if (_remoteDisplayName.length == 0) {
                _logoTextImage.string = [_remotePartyName substringToIndex:2];
            } else {
                _logoTextImage.string = [_remoteDisplayName substringToIndex:1];
            }
            
        }
    }
    
    _logoTextImage.textImageLabel.font = [UIFont fontWithName:@"Arial" size:50];
    _logoTextImage.raduis = 60.0;
    _logoTextImage.layer.borderWidth = 0.1;
    _logoTextImage.layer.cornerRadius = _logoTextImage.bounds.size.width / 2;
    _logoTextImage.clipsToBounds = YES;
    [self.view addSubview:_logoTextImage];
    
    
    [_logoTextImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(_logoImageView.mas_centerX);
        make.top.equalTo(_logoImageView.mas_top).with.offset(0);
        make.width.equalTo(@(130));
        make.height.equalTo(@(130));
    }];
}


-(void)setvideobuttonimg{
    
    if (_hasVideo){
        [_scrollVideoButton  setImage:[UIImage imageNamed:@"qudianhua"] forState:UIControlStateNormal];
        _scrollOnOffCameraButton.hidden = NO;
        _scrollFrontBackButton.hidden = NO;
    }else
    {
        
        [_scrollVideoButton  setImage:[UIImage imageNamed:@"qushiping"] forState:UIControlStateNormal];
        _scrollOnOffCameraButton.hidden = YES;
        _scrollFrontBackButton.hidden = YES;
    }
}

-(void)mas{
    
    
    [self setvideobuttonimg];
    
    [_logoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.view.mas_centerX);
        
        make.top.equalTo(self.view.mas_top).with.offset(120);
        
        make.width.equalTo(@(130));
        
        make.height.equalTo(@(130));
        
        
    }];
    
    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(_callView.mas_centerX);
        
        make.top.equalTo(_remoteBgImageView.mas_bottom).with.offset(20);
        
        make.width.equalTo(@(ScreenWid));
        
        make.height.equalTo(@(25));
        
        
    }];
    
    [_timeLongLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(_callView.mas_centerX);
        
        make.top.equalTo(_nameLabel.mas_top).with.offset(30);
        
        make.width.equalTo(@(ScreenWid));
        
        make.height.equalTo(@(25));
        
        
    }];
    
    
    [_recordImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_remoteBgImageView.mas_top).with.offset(0);
        
        make.left.equalTo(_remoteBgImageView.mas_right).with.offset(0);
        
        make.width.equalTo(@(44));
        
        make.height.equalTo(@(44));
        
        
    }];
    
    
    
    
    if  (_hasVideo){
        
        
        
        [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            //            make.left.equalTo(_callView.mas_left).with.offset(50);
            
            make.left.equalTo(_hiddenButton.mas_left).with.offset(0);
            
            //            make.top.equalTo(_callView.mas_top).with.offset(50);
            
            make.top.equalTo(_hiddenButton.mas_bottom).with.offset(15);
            
            make.width.equalTo(@(150));
            
            make.height.equalTo(@(25));
            
            
        }];
        
        [_timeLongLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            //   make.left.equalTo(_callView.mas_left).with.offset(50);
            
            make.left.equalTo(_hiddenButton.mas_left).with.offset(0);
            
            make.top.equalTo(_nameLabel.mas_bottom).with.offset(10);
            
            make.width.equalTo(@(100));
            
            make.height.equalTo(@(25));
            
            
        }];
        
        [_recordImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(_timeLongLabel.mas_centerX);
            
            make.top.equalTo(_timeLongLabel.mas_bottom).with.offset(0);
            
            make.width.equalTo(@(44));
            
            make.height.equalTo(@(44));
        }];
    }
    
    [_stateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(_callView.mas_centerX);
        
        make.top.equalTo(_timeLongLabel.mas_bottom).with.offset(10);
        
        make.width.equalTo(@(ScreenWid));
        
        make.height.equalTo(@(30));
        
        
    }];
    
    
    //bottom view mas
    
    [_scrollBottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(_callView.mas_centerX);
        
        make.bottom.equalTo(_callView.mas_bottom).with.offset(0);
        
        make.width.equalTo(@(ScreenWid));
        
        make.height.equalTo(@(200));
        
        
    }];
    
    
    //   _scrollBottomView.backgroundColor = [UIColor redColor];
    
    
    [_hungupButton2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(_callView.mas_centerX);
        
        make.bottom.equalTo(_callView.mas_bottom).with.offset(-35);
        
        make.width.equalTo(@(70));
        
        make.height.equalTo(@(70));
        
        
    }];
    
    
    
    [_scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(_callView.mas_centerX);
        
        make.top.equalTo(_scrollBottomView.mas_top).with.offset(0);
        
        make.width.equalTo(@(320));
        
        make.height.equalTo(@(70));
        
        
    }];
    
    
    [_pageIndicator mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(_callView.mas_centerX);
        
        make.top.equalTo(_scrollView.mas_bottom).with.offset(-5);
        
        make.width.equalTo(@(40));
        
        make.height.equalTo(@(37));
        
        
    }];
    
    
    
}


#pragma mark

-(void)onInviteUpdated:(NSNotification*)not{
    
    
    BOOL  onvideo = [not.object boolValue];
    
    NSLog(@"onvideo=======%d",onvideo);
    
    if (onvideo != _hasVideo) {
        [self openvideoButton];
    }
    
    if (!_showcallview &&  !self.view.window) {
        
        [[AppDelegate sharedInstance] addremoteVideoView:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId andvideo:onvideo andTimeInterval:_history.mTimeStart];
        
    }
    
    [self setvideobuttonimg];
}

-(void)stopTimer{
    
    [_beginTimeTimer invalidate];
    _beginTimeTimer =nil;
}



-(void)setlogoview{
    _remoteBgImageView.hidden = NO;
    _logoImageView.hidden = NO;
    
    _logoImageView.image = [UIImage imageNamed:@"headport"];
    
    _remoteBgImageView.image =  [UIImage imageNamed:@"headport"];
    
    _remoteBgImageView.layer.cornerRadius = _remoteBgImageView.bounds.size.width / 2.0f;
    _remoteBgImageView.layer.masksToBounds = YES;
    _logoImageView.layer.cornerRadius = _logoImageView.bounds.size.width / 2.0f;
    _logoImageView.layer.masksToBounds = YES;
    
}

#pragma mark -
#pragma mark viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopTimer) name:@"stopTimer" object:nil];
    
    if (_callType ==0) {
        
        //   _hungupButton .hidden = YES;
        
        _videoButton.hidden = YES;
        _audioButton.hidden = YES;
    }
    
    
    tempwidth = ScreenWid-1;
    tempheight = 288;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onInviteUpdated:) name:@"onInviteUpdated" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onStartRecord2) name:@"Enalbe_Call_Record" object:nil];
    
    
    // Do any additional setup after loading the view.
    
    _mIsConference = NO;
    _nameLabel.text = _remoteDisplayName;
    NSLog(@"_remoteDisplayName======%@",_remoteDisplayName);
    
    NSString*str5 = [_remoteDisplayName stringByRemovingPercentEncoding];
    _nameLabel.text = str5;
    
    _remoteLabel.text = _remotePartyName;
    
    
    
    if  ([ _remoteLabel.text  rangeOfString:@"@"].location !=NSNotFound){
        
        NSArray *strs = [ _remoteLabel.text  componentsSeparatedByString:@"@"];
        _remoteLabel.text  = strs[0];
    }
    
    
    NSDictionary *mapper = [contactView numbers2ContactsMapper];
    NSString * tempPattyName = _remotePartyName;
    
    if ([tempPattyName rangeOfString:@"@"].location==NSNotFound) {
        
        tempPattyName = [NSString stringWithFormat:@"%@@%@",tempPattyName,shareAppDelegate.portSIPHandle.mAccount.userDomain];
        
    }
    
    Contact *contact = [mapper objectForKey:tempPattyName];
    _callNameLabel.text = contact.displayName;
    
    
    if (contact && contact.displayName) {
        _nameLabel.text = contact.displayName;
    }
    if (contact) {
        if (contact.picture) {
            _remoteBgImageView.hidden = NO;
            _logoImageView.hidden = NO;
            
            _logoImageView.image = [UIImage imageWithData:contact.picture];
            _remoteBgImageView.image = [UIImage imageWithData:contact.picture];
            
            _remoteBgImageView.layer.cornerRadius = _remoteBgImageView.bounds.size.width / 2.0f;
            _remoteBgImageView.layer.masksToBounds = YES;
            _logoImageView.layer.cornerRadius = _logoImageView.bounds.size.width / 2.0f;
            _logoImageView.layer.masksToBounds = YES;
        } else {
            _remoteBgImageView.hidden = YES;
            _logoImageView.hidden = YES;
            
            [self createCallTextImage];
        }
        
    } else {
        [self setlogoview];
        
    }
    
    _reocrdImageShowed = NO;
    _cameraOptionImageView.layer.cornerRadius = 12;
    _cameraOptionImageView.layer.masksToBounds = YES;
    
    [self setCallButtonRoundCorner];
    
    [self setScrollButtonRoundCorner];
    
    _pageIndicator.userInteractionEnabled = NO;
    
    
    [self setScrollViewContent];
    _earlyMedia = NO;
    
    if (_hasVideo) {
        CGRect lineOneLabelRect = _lineOneLabel.frame;
        //        lineOneLabelRect.origin.x = self.view.bounds.size.width - 185;
        //lineOneLabelRect.origin.x = self.view.bounds.size.width - 245;
        lineOneLabelRect.origin.x = self.view.bounds.size.width - 70;
        lineOneLabelRect.size.width = 70;
        _lineOneLabel.frame = lineOneLabelRect;
        
        
        CGRect lineTwoLabelRect = _lineTwoLabel.frame;
        //lineTwoLabelRect.origin.x = self.view.bounds.size.width - 245;
        lineTwoLabelRect.origin.x = self.view.bounds.size.width - 70;
        lineTwoLabelRect.size.width = 70;
        _lineTwoLabel.frame = lineTwoLabelRect;
    }
    
    [portSIPEngine setVideoDeviceId:1];
    _mCameraDeviceId = 1;
    
    _mLastOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChange:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [_localVideoView initVideoRender];
    [_remoteVideoView initVideoRender];
    self.remoteVideoView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self mas];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [self onCloseVideo];
    
    if (_mIsConference) {
        
        [portSIPEngine setConferenceVideoWindow:nil];
    }
    
    _showcallview = NO;
    
    
    [super viewWillDisappear:animated];
    [AppDelegate.sharedInstance.numpadViewController refreshReturnButtonState];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addRotationAnim];
    
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
    [self adjustButtonState];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    _showcallview = YES;
    
    
    
#ifdef OEM_FIXEDHOST
    [self getCreditTime];
#endif
    
    if ([shareAppDelegate.callManager getConnectCallNum] == 2 && !_mIsConference) {
        
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setLineInfo) userInfo:nil repeats:YES];
        
    }
    else{
        _nameLabel.hidden = NO;
        _timeLongLabel.hidden = NO;
        _lineOneView.hidden = YES;
        _lineTwoView.hidden = YES;
    }
    
    //[self adjustWidgetFrame];
    
    [self onCloseVideo];
    if (_hasVideo && _callState == CALL_STATE_INCALL) {
        if (([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)) {
            //            [_callView removeFromSuperview];
            
            _mIsLandscape = YES;
            [self setScrollViewContent];
        }
        else{
            //            [self.view addSubview:_callView];
            _mIsLandscape = NO;
            [self setScrollViewContent];
        }
    }
    [self onOpenVideo];
    
    [self fontChange:nil];
    
    [_dtmfView removeFromSuperview];
    _dtmfView.tag = 0;
    _nameLabel.tag = 0;
    _scrollBottomView.hidden = NO;
    
    
    
    if(!_isCallBuildSuccess && _callState == CALL_STATE_INCALL){
        [self onBuildCallState];
    }
    [[AppDelegate sharedInstance] deleteremoteVideoView];
}

- (void)fontChange:(NSNotification*)notification
{
    _remoteLabel.font = SYSTEM_FONT;
    _callingStateLabel.font = SYSTEM_FONT;
    _stateLabel.font = SYSTEM_FONT;
    
    _nameLabel.font = SYSTEM_FONT;
    _timeLongLabel.font = SYSTEM_FONT;
    
    [_nameLabel setFont:[UIFont systemFontOfSize:20]];
    
    [_timeLongLabel setFont:[UIFont systemFontOfSize:16]];
    
    NSLog(@"set font");
    
    _costRate.font = SYSTEM_FONT;
    _lineOneDisplayName.font = SYSTEM_FONT;
    _lineOneLabel.font = SYSTEM_FONT;
    _lineTwoDisplayName.font = SYSTEM_FONT;
    _lineTwoLabel.font = SYSTEM_FONT;
    
}

- (void)setScrollViewContent
{
    
    CGSize contentSize = _scrollView.bounds.size;
    contentSize.width *= 2;
    [_scrollView setContentSize:contentSize];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    [_scrollView addSubview:_scrollViewPageOne];
    
    CGRect rect = _scrollViewPageTwo.frame;
    rect.origin.x = rect.size.width;
    [_scrollViewPageTwo setFrame:rect];
    [_scrollView addSubview:_scrollViewPageTwo];
}

- (void)adjustWidgetFrame
{
    CGRect bottomRect = _scrollBottomView.frame;
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    if(_mIsLandscape){//
        bottomRect.size.width = _scrollView.frame.size.width + _hungupButton2.frame.size.width + _pageIndicator.frame.size.width;//+35*2;
        bottomRect.size.height =_hungupButton2.frame.size.height;
        
        [self moveView:_pageIndicator posX:0 posY:(bottomRect.size.height - _pageIndicator.bounds.size.height) / 2];
        
        [self moveView:_scrollView posX:_pageIndicator.frame.size.width posY:(bottomRect.size.height - _scrollView.bounds.size.height) / 2];
        CGRect moveto = _hungupButton2.frame;
        moveto.origin.x = _scrollView.frame.size.width + _pageIndicator.frame.size.width;//+35;
        moveto.origin.y = 0;
        [_hungupButton2 setFrame:moveto];
        
        _pageIndicator.hidden = NO;
        
        
        bottomRect.origin.x = (screenRect.size.height-bottomRect.size.width)/2;
        bottomRect.origin.x = bottomRect.origin.x>0?bottomRect.origin.x:0;
        bottomRect.origin.y = screenRect.size.width - bottomRect.size.height-10;
        
    }else{
        
        CGRect moveto = _hungupButton2.frame;
        moveto.origin.x = (screenRect.size.height - moveto.size.width)/2;
        moveto.origin.y = _scrollView.frame.size.height +_pageIndicator.frame.size.height+10;
        [_hungupButton2 setFrame:moveto];
        
        [self moveView:_pageIndicator posX:(screenRect.size.height-_pageIndicator.frame.size.width)/2 posY:_scrollView.frame.size.height+10];
        [self moveView:_scrollView posX:0 posY:0];
        
        bottomRect.size.height = _scrollView.frame.size.height +_pageIndicator.frame.size.height+20+_hungupButton2.frame.size.height;
        bottomRect.size.width = _scrollView.frame.size.width;
        bottomRect.origin.x = 0;//(screenRect.size.height - bottomRect.size.width)/2;
        bottomRect.origin.y = screenRect.size.width - bottomRect.size.height;
    }
    
    
    [_scrollBottomView setFrame:bottomRect];
}

- (void)scaleAnim
{
    if (!_circleScale) {
        
        CGRect rect = _logoImageView.frame;
        rect.size.height += 4;
        rect.size.width += 4;
        rect.origin.x -= 2;
        rect.origin.y -= 2;
        _circleScale = [[UIView alloc] initWithFrame:rect];
        _circleScale.layer.cornerRadius = _logoImageView.frame.size.width / 2;
        _circleScale.layer.borderColor = [UIColor colorWithRed:59.0 / 255 green:174.0 / 255 blue:218.0 / 255 alpha:1].CGColor;
        _circleScale.layer.borderWidth = 2;
        _circleScale.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_circleScale];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        [anim setDuration:2.0f];
        [anim setFromValue:@1.0];
        [anim setToValue:@1.6f];
        [anim setRepeatCount:MAXFLOAT];
        
        CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [anim2 setFromValue:@1.0];
        [anim2 setToValue:@0];
        [anim2 setDuration:2.0f];
        [anim2 setRepeatCount:MAXFLOAT];
        
        //    [anim setFillMode:kCAFillModeForwards];
        //    [anim setRemovedOnCompletion:NO];
        
        [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        
        [_circleScale.layer addAnimation:anim forKey:nil];
        [_circleScale.layer addAnimation:anim2 forKey:nil];
    }
}

- (void)addRotationAnim
{//旋转Logo
    if( _callState !=  CALL_STATE_INCOMING &&
       _callState !=  CALL_STATE_OUTGOING){
        return;
    }
    
    [self scaleAnim];
    
    if (!_circleRotate) {
        
        _circleRotate = [CALayer layer];
        _circleRotate.cornerRadius = _logoImageView.frame.size.width / 2;
        [_circleRotate setBounds:_logoImageView.bounds];
        [_circleRotate setPosition:_logoImageView.center];
        [_circleRotate setContents:(id)[UIImage imageNamed:@"call_button_logo_arcshape.png"].CGImage];
        _circleRotate.masksToBounds = YES;
        [self.view.layer addSublayer:_circleRotate];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        
        [anim setRepeatDuration:HUGE_VALF];
        [anim setToValue:@(-M_PI * 2)];
        
        //    [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        
        [anim setDuration:2];
        [anim setRemovedOnCompletion:NO];
        [anim setFillMode:kCAFillModeForwards];
        
        [_circleRotate addAnimation:anim forKey:@"rotationAnim"];
    }
}

- (void)timeFunction
{
    
    NSTimeInterval callTime = [[NSDate date] timeIntervalSince1970] - _history.mTimeStart;
    _duration =  [NSString stringWithFormat:@"%02li:%02li:%02li",
                  lround(floor(callTime / 3600.)) % 100,
                  lround(floor(callTime / 60.)) % 60,
                  lround(floor(callTime)) % 60];
    
    _timeLongLabel.text = _duration;
    [[AppDelegate sharedInstance ] settimelab:_duration];
}

#pragma mark - setFirstFrame
-(void)setFirstFrame{
    
    int   videoResolution =  databaseManage.mOptions.videoResolution;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGFloat firstWidth = 128;
        CGFloat firistHeight = 0;
        CGFloat tempwin ;
        CGFloat temphei;
        
        
        if (ScreenHeight > ScreenWid) {
            
            tempwin = ScreenHeight;
            temphei =ScreenWid;
            
            _scrollVideoButton .userInteractionEnabled = YES;
            
            
            if (videoResolution==0) {
                firistHeight = firstWidth *176/144;
            }
            else if(videoResolution ==1){
                firistHeight = firstWidth *352/288;
            }
            else if(videoResolution ==2){
                firistHeight = firstWidth *1280/720;
            }
            
        }
        else
        {
            tempwin = ScreenWid;
            temphei =ScreenHeight;
            
            _scrollVideoButton .userInteractionEnabled = NO;
            
            
            if (videoResolution==0) {
                firistHeight = firstWidth *144/176;
                
            }
            else if(videoResolution ==1){
                firistHeight = firstWidth *288/352;
            }
            else if(videoResolution ==2){
                firistHeight = firstWidth *720/1280;
                
            }
            
        }
        
        [_localVideoView setFrame:CGRectMake(ScreenWid-firstWidth-10, 20, firstWidth, firistHeight)];
        
    });
    
    
}












#pragma mark

/**
 */
- (void)onBuildCallState
{
    
    [self mas];
    
    
    _callandhunupview.hidden = YES;
    
    
    _remoteBgImageView.hidden = _hasVideo;
    _callTextImage.hidden = _hasVideo;
    
    if (!_hasVideo) {
        [_hiddenButton setImage:[UIImage imageNamed:@"call_audio_minimize_ico_def"] forState:UIControlStateNormal];
        [_hiddenButton setImage:[UIImage imageNamed:@"call_audio_minimize_ico_pre"] forState:UIControlStateHighlighted];
        _hiddenButton.tag = 0;
        
        
        _scrollOnOffCameraButton.hidden = YES;
        _scrollFrontBackButton.hidden = YES;
    } else {
        [_hiddenButton setImage:[UIImage imageNamed:@"call_vedio_minimize_ico"] forState:UIControlStateNormal];
        [_hiddenButton setImage:nil forState:UIControlStateHighlighted];
        _hiddenButton.tag = 1;
        
        
        
        _scrollOnOffCameraButton.hidden = NO;
        _scrollFrontBackButton.hidden = NO;
        
        [self handleTapGesture:nil];
        
        
    }
    
    int outRountType = 0;
    
    if (_hasVideo) {
        if (![soundServiceEngine hasHeadset]) {
            outRountType = 1;
        }
        CGRect rect = _localVideoView.frame;
        rect.origin.x = self.view.frame.size.width - _localVideoView.frame.size.width;
        rect.origin.y = 20;
        
        if (!isfirtcomeon) {
            
            [self setFirstFrame];
            
            isfirtcomeon = YES;
            
        }
        
        [self moveView:_nameLabel posX:10 posY:60];
        
        [self moveView:_timeLongLabel posX:_nameLabel.frame.origin.x posY:_nameLabel.frame.size.height+_nameLabel.frame.origin.y];
        
        [_nameLabel setTextAlignment:NSTextAlignmentLeft];
        [_timeLongLabel setTextAlignment:NSTextAlignmentLeft];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_localVideoView addGestureRecognizer:panGesture];
        
        [_callView addSubview:_localVideoView];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_callView addGestureRecognizer:tap];
        
        [self onOpenVideo];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self updateAudioRouteButton:1];
            [shareAppDelegate setAudioOutRoute:outRountType];
            
        });
        
        
    }
    
    
    UISwipeGestureRecognizer *swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipGesture:)];
    swipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [_callView addGestureRecognizer:swipe];
    
    UISwipeGestureRecognizer *swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipGesture:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [_callView addGestureRecognizer:swiperight];
    
    _beginTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeFunction) userInfo:nil repeats:YES];
    [self addViewFadeAnimation];
    
    _hungupButton.hidden = YES;
    
    [self.view addSubview:_callView];
    
    [_callView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).with.offset(0);
        
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(0);
        
        make.left.mas_equalTo(self.view.mas_left).with.offset(0);
        
        make.right.mas_equalTo(self.view.mas_right).with.offset(0);
    }];
    
    [_remoteBgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(_callView.mas_centerX);
        
        make.top.equalTo(_callView.mas_top).with.offset(120);
        
        make.width.equalTo(@(130));
        
        make.height.equalTo(@(130));
        
        
    }];
    
    _isCallBuildSuccess = YES;
}

-(void)handleSwipGesture:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        if (_scrollView.contentOffset.x == _scrollView.frame.size.width) {
            [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            _pageIndicator.currentPage = 0 ;
        }
    }
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (_scrollView.contentOffset.x == 0) {
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
            _pageIndicator.currentPage = 1;
        }
    }
}

-(void)timerSuicideTick:(NSTimer*)timer{
    [self performSelectorOnMainThread:@selector(closeView) withObject:nil waitUntilDone:NO];
}

-(void)closeView{
    
    if ([shareAppDelegate.callManager getConnectCallNum]){
        shareAppDelegate.numpadViewController.returnCallButton.alpha = 0;
    }
    
    [shareAppDelegate.numpadViewController refreshReturnButtonState];
    
    NSLog(@"callview dismissViewControllerAnimated");
    
    [self dismissViewControllerAnimated:NO completion:^{
        if ([shareAppDelegate.callManager getConnectCallNum]) {
            
            
            HSSession* otherSession = [shareAppDelegate.callManager findAnotherCall:_sessionId];
            if(otherSession)
            {
                [shareAppDelegate onBackCall:otherSession.uuid];
            }
        }
    }];
    
}

- (void)terminateCall
{
    [self closeConference];
    [self onCloseVideo];
    
    [self.view.layer removeAllAnimations];
    [_circleScale.layer removeAllAnimations];
    
    _callState = CALL_STATE_TERMINATED;
    
    _callingStateLabel.text = _stateLabel.text;
    _timeLongLabel.text = @"00:00:00";
    // [_beginTimeTimer invalidate];
    
    [soundServiceEngine stopRingBackTone];
    [soundServiceEngine stopRingTone];
    _scrollMicoButton.enabled = NO;
    _scrollLoudlyButton.enabled = NO;
    _scrollVideoButton.enabled = NO;
    _scrollDtmfButton.enabled = NO;
    _scrollAddButton.enabled = NO;
    _scrollHoldButton.enabled = NO;
    _scrollRecordButton.enabled = NO;
    _scrollAudioButton.enabled = NO;
    _hungupButton2.backgroundColor = [UIColor grayColor];
    
    if (!databaseManage.mOptions.enableCallKit){
        //Haven't callkit, show close view
        [NSTimer scheduledTimerWithTimeInterval: kCallTimerSuicide
                                         target: self
                                       selector: @selector(timerSuicideTick:)
                                       userInfo: nil
                                        repeats: NO];
        UIView *maskView = [[UIView alloc] initWithFrame:self.view.frame];
        [maskView setBackgroundColor:[UIColor blackColor]];
        maskView.alpha = 0.5;
        [self.view addSubview:maskView];
    }
    else{
        [self performSelectorOnMainThread:@selector(closeView) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark- closeCall

- (void)closeCall{
    
    [_beginTimeTimer invalidate];
    _beginTimeTimer =nil;
    
    //Add call record to database and recent view.
    if (_isCallBuildSuccess) {
        _history.mTimeEnd = [[NSDate date] timeIntervalSince1970];
    }
    else{
        if(IS_EVENT_INCOMING(_history.mStatus)) {
            _history.mStatus = INCOMING_FAILED;
        }else{
            _history.mStatus = OUTGOING_FAILED;
        }
    }
    _callState = CALL_STATE_TERMINATED;
    
    
    if ([_history.mRemoteParty rangeOfString:@"@"].location ==NSNotFound) {
        
        _history.mRemoteParty = [NSString stringWithFormat:@"%@@%@",_history.mRemoteParty,shareAppDelegate.portSIPHandle.mAccount.userDomain];
        
    }
    
    [databaseManage insertHistory:_history];
    
    [recentView addNewHistroy:_history];
    
    _stateLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Call ending", @"Call ending")];
    
    _hungupButton.backgroundColor = [UIColor grayColor];
    _audioButton.backgroundColor = [UIColor grayColor];
    _videoButton.backgroundColor = [UIColor grayColor];
    _microButton1.enabled = NO;
    _loudSpeaker1.enabled = NO;
    
    [self terminateCall];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OnTransfer object:@(8)];
    
    [[AppDelegate sharedInstance] deleteremoteVideoView];
}

#pragma mark - hiddenCallviewAction

- (IBAction)hiddenCallviewAction:(id)sender {
    int  num = [shareAppDelegate.callManager getConnectCallNum];
    
    if (!_mIsConference && num==1) {
        
        [[AppDelegate sharedInstance] addremoteVideoView:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId andvideo:_hasVideo andTimeInterval:_history.mTimeStart];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OnTransfer object:@([shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId)];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)hangupCall:(id)sender {
    
    [shareAppDelegate endCall:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId];
    
    [shareAppDelegate.myTimer timeInterval];
    
    shareAppDelegate.myTimer = nil;
}

- (IBAction)incomingAudioCall:(id)sender {
    
    _audioButton.hidden = NO;
    _videoButton.hidden = NO;
    
    _hasVideo = NO;
answerCall:isVideo:answerByCallKit:
    //    -(BOOL)answerCall:(long)sessionId isVideo:(BOOL)isVideo answerByCallKit:(BOOL)answerByCallKit;
    [shareAppDelegate.callManager answerCall:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId isVideo:NO answerByCallKit:FALSE];
}

- (IBAction)incomingVideoCall:(id)sender {
    
    
    _audioButton.hidden = NO;
    _videoButton.hidden = NO;
    
    _hasVideo = YES;
    
    [shareAppDelegate.callManager answerCall:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId isVideo:YES answerByCallKit:FALSE];
}

- (IBAction)dtmfButtonClick:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (_dtmfDisplayLabel.tag == 0) {
        _dtmfDisplayLabel.text = @"";
        _dtmfDisplayLabel.tag = 1;
    }
    
    NSString *dtmfStr = nil;
    if (btn.tag == 10) {
        dtmfStr = [_dtmfDisplayLabel.text stringByAppendingString:@"*"];
        _dtmfDisplayLabel.text = dtmfStr;
        [shareAppDelegate.callManager playDtmf:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId tone:(int)btn.tag];
    }
    else if (btn.tag == 11)
    {
        dtmfStr = [_dtmfDisplayLabel.text stringByAppendingString:@"#"];
        _dtmfDisplayLabel.text = dtmfStr;
        [shareAppDelegate.callManager playDtmf:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId tone:(int)btn.tag];
    }
    else if (btn.tag == 14){
        [_dtmfView removeFromSuperview];
        _dtmfView.tag = 0;
        _nameLabel.tag = 0;
        
        _scrollBottomView.hidden = NO;
    }
    else{
        dtmfStr = [_dtmfDisplayLabel.text stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)btn.tag]];
        _dtmfDisplayLabel.text = dtmfStr;
        [shareAppDelegate.callManager playDtmf:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId tone:(int)btn.tag];
    }
    
}
#pragma mark - scrollButtonClick
- (IBAction)scrollButtonClick:(id)sender {
    
    UIButton *btn = (UIButton*)sender;
    if (btn == _scrollDtmfButton) {
        if (_cameraOptionView.tag == 1) {
            [_cameraOptionView removeFromSuperview];
            _cameraOptionView.tag = 0;
        }
        _dtmfDisplayLabel.text = @"";
        CGRect rect = _dtmfView.frame;
        CGRect rootRect  = self.view.bounds;
        
        if (_mIsLandscape) {
            rect.origin = CGPointMake((rootRect.size.width - rect.size.width) / 2, rootRect.size.height - rect.size.height);
        } else {
            rect.origin = CGPointMake(0, rootRect.size.height - rect.size.height);
        }
        
        _dtmfView.frame = rect;
        
        _dtmfView.tag = 1;
        [self.view addSubview:_dtmfView];
        
        [_hiddenDtmfButton setTitle:NSLocalizedString(@"HIDE", @"HIDE") forState:UIControlStateNormal];
        
        
        CGFloat temphight = 350;
        
        if (IS_IPHONE_5 || IS_IPHONE_4) {
            
            temphight = 300;
            
            
        }
        
        [_dtmfView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(_callView.mas_centerX);
            
            make.bottom.equalTo(_callView.mas_bottom).with.offset(0);
            
            make.width.equalTo(@(ScreenWid));
            
            make.height.equalTo(@(temphight));
            
            
            
        }];
        
        
        
        [_dtmfBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(_callView.mas_centerX);
            
            make.bottom.equalTo(_callView.mas_bottom).with.offset(0);
            
            make.width.equalTo(@(ScreenWid));
            
            make.height.equalTo(@(temphight));
        }];
        
        
        if (_dtmfView.isHidden) {
            _dtmfView.hidden = NO;
        }
        
        _scrollBottomView.hidden = YES;
        
        return;
    }
    
    if (btn == _scrollVideoButton) {
        
        [self  openvideoButton];
        
        return;
    }
    
    if (btn == _scrollMicoButton || btn == _microButton1) {
        BOOL muted = !_scrollMicoButton.selected;
        
        if (_mIsConference) {
            [shareAppDelegate.callManager muteAllCall:muted];
        }
        else{
            [shareAppDelegate.callManager muteCall:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId muted:muted];
        }
        return;
    }
    
    if (btn == _scrollLoudlyButton || btn == _loudSpeaker1) {
        
        if([soundServiceEngine isBlueToothConnected]){
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"BlueTooth", @"BlueTooth"),
                                          NSLocalizedString(@"Iphone", @"Iphone"),
                                          NSLocalizedString(@"Speaker", @"Speaker"),nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [actionSheet showInView:self.view];
        }else{
            if (shareAppDelegate.audioOutRouteType != 0) {
                
                [shareAppDelegate setAudioOutRoute:0];
                
                shareAppDelegate.audioOutRouteType =0;
                [self updateAudioRouteButton:0];
            }
            else{
                [shareAppDelegate setAudioOutRoute:1];
                shareAppDelegate.audioOutRouteType =1;
                [self updateAudioRouteButton:1];
            }
        }
        return;
    }
    
    if (btn == _scrollHoldButton) {
        
        BOOL onHold = !_scrollHoldButton.selected;
        
        if (onHold) {
            if (_mIsConference) {
                [shareAppDelegate.callManager holdAllCall:onHold];
            }
            else{
                [shareAppDelegate.callManager holdCall:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId onHold:onHold];
            }
        }
        else{
            if (_mIsConference) {
                [shareAppDelegate.callManager holdAllCall:onHold];;
            }
            else{
                [shareAppDelegate.callManager holdCall:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId onHold:onHold];
            }
            [self onOpenVideo];
        }
        _scrollHoldButton.selected = onHold;
    }
    
    if (btn == _scrollAddButton) {
        [self addConference];
    }
    
    if (btn == _scrollAudioButton) {
        _mCurrentCallingCount = [shareAppDelegate.callManager getConnectCallNum];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setSessid" object:@([shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId)];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OnTransfer object:@(-1)];
        
        [self dismissViewControllerAnimated:NO completion:nil];
        
        [tabBarCtr setSelectedIndex:kTabBarIndex_Numpad];
        //        }
    }
    
    if (btn == _scrollRecordButton) {
        if (!_scrollRecordButton.selected) {
            [self onStartRecord];
        }
        else{
            [self onStopRecord];
        }
        _scrollRecordButton.selected = !_scrollRecordButton.selected;
    }
    
    if (btn == _scrollFrontBackButton) {
        if (_scrollFrontBackButton.tag == 2) {
            _scrollFrontBackButton.tag = 1;
            _scrollFrontBackButton.selected = NO;
            [self onCloseVideo];
            [self setFrontCamera];
            [self onOpenVideo];
            if (!_mIsConference) {
                _localVideoView.hidden = NO;
            }
        } else {
            _scrollFrontBackButton.tag = 2;
            _scrollFrontBackButton.selected = YES;
            [self onCloseVideo];
            [self setBackCamera];
            [self onOpenVideo];
            if (!_mIsConference) {
                _localVideoView.hidden = NO;
            }
            
        }
        
    }
    
    if (btn == _scrollOnOffCameraButton) {
        if (_scrollOnOffCameraButton.tag == 4) {
            _scrollOnOffCameraButton.tag = 5;
            [self setNoneCamera];
            
            _localVideoView.hidden = YES;
            [_scrollOnOffCameraButton setImage:[UIImage imageNamed:@"call_video_tab_on_camera_ico_def"] forState:UIControlStateNormal];
            
        } else {
            _scrollOnOffCameraButton.tag = 4;
            [_scrollOnOffCameraButton setImage:[UIImage imageNamed:@"call_video_tab_off_camera_ico_def"] forState:UIControlStateNormal];
            
            [self onCloseVideo];
            [self setFrontCamera];
            [self onOpenVideo];
            if (!_mIsConference) {
                _localVideoView.hidden = NO;
            }
            
        }
        
    }
}


#pragma mark - videoButton
-(void)openvideoButton{
    
    
    //   _scrollVideoButton.selected = !_scrollVideoButton.selected;
    
    if (!_hasVideo) {
        _callTextImage.hidden = YES;
        _remoteBgImageView.hidden = YES;
        CGRect rect = _localVideoView.frame;
        rect.origin.x = self.view.frame.size.width - _localVideoView.frame.size.width;
        rect.origin.y = 20;
        
        
        
        [self moveView:_nameLabel posX:10 posY:60];
        [self moveView:_timeLongLabel posX:_nameLabel.frame.origin.x posY:_nameLabel.frame.size.height +_nameLabel.frame.origin.y];
        [_nameLabel setTextAlignment:NSTextAlignmentLeft];
        [_timeLongLabel setTextAlignment:NSTextAlignmentLeft];
        
        [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(_hiddenButton.mas_left).with.offset(0);
            
            make.top.equalTo(_hiddenButton.mas_bottom).with.offset(15);
            
            make.width.equalTo(@(150));
            
            make.height.equalTo(@(25));
            
            
        }];
        
        [_timeLongLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(_hiddenButton.mas_left).with.offset(0);
            
            make.top.equalTo(_nameLabel.mas_bottom).with.offset(10);
            
            make.width.equalTo(@(100));
            
            make.height.equalTo(@(25));
            
            
        }];
        
        [_recordImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(_timeLongLabel.mas_centerX);
            
            make.top.equalTo(_timeLongLabel.mas_bottom).with.offset(0);
            
            make.width.equalTo(@(44));
            
            make.height.equalTo(@(44));
            
            
        }];
        
        
        
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_localVideoView addGestureRecognizer:panGesture];
        [_callView addSubview:_localVideoView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_callView addGestureRecognizer:tap];
        
        
        int ret = [portSIPEngine updateCall:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId enableAudio:true enableVideo:true];
        
        _hasVideo = YES;
        _lastLocation = _nameLabel.frame.origin;
        _logoImageView.hidden  =YES;
        _callTextImage.hidden = YES;
        _localVideoView .hidden = NO;
        _remoteVideoView.hidden = NO;
        
        
        [self onOpenVideo];
        [self setFirstFrame];
        
        
        [shareAppDelegate setAudioOutRoute:1];
        
        shareAppDelegate.audioOutRouteType =1;
        
        [self updateAudioRouteButton:1];
        
        
    } else {
        
        _localVideoView .hidden = YES;
        
        _remoteVideoView.hidden = YES;
        
        [self onCloseVideo];
        
        NSDictionary *mapper = [contactView numbers2ContactsMapper];
        Contact *contact = [mapper objectForKey:_remotePartyName];
        
        if (contact.picture) {
            
            _callTextImage.hidden = YES;
            
            _logoImageView.hidden  = NO;
            
            
            
            [_logoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.centerX.equalTo(_callView.mas_centerX);
                
                make.top.equalTo(_callView.mas_top).with.offset(120);
                
                make.width.equalTo(@(130));
                
                make.height.equalTo(@(130));
                
                
            }];
            
            [self.view bringSubviewToFront:_logoImageView];
            
            
        }
        else
        {
            
            _callTextImage.hidden = NO;
            
            _logoImageView.hidden  = YES;
            
        }
        
        
        
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _timeLongLabel.textAlignment = NSTextAlignmentCenter;
        
        
        [portSIPEngine updateCall:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId enableAudio:true enableVideo:false];
        
        _hasVideo = NO;
        _lastLocation = _nameLabel.frame.origin;
        
        
        
        [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(_callView.mas_centerX);
            
            make.top.equalTo(_callView.mas_top).with.offset(270);
            
            make.width.equalTo(@(ScreenWid));
            
            make.height.equalTo(@(25));
            
            
        }];
        
        [_timeLongLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(_callView.mas_centerX);
            
            make.top.equalTo(_nameLabel.mas_bottom).with.offset(10);
            
            make.width.equalTo(@(ScreenWid));
            
            make.height.equalTo(@(25));
            
            
        }];
        
        
        
        [_recordImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(_remoteBgImageView.mas_top).with.offset(0);
            
            make.left.equalTo(_remoteBgImageView.mas_right).with.offset(0);
            
            make.width.equalTo(@(44));
            
            make.height.equalTo(@(44));
            
            
        }];
        
    }
    
    
    [self  setvideobuttonimg];
    
    
}


#pragma mark

-(void)addConference{
    
    _mCurrentCallingCount = [shareAppDelegate.callManager getConnectCallNum];
    
    if (_mCurrentCallingCount == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setSessid" object:@([shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId)];
        [[NSNotificationCenter defaultCenter] postNotificationName:OnTransfer object:@(-2)];
        [self dismissViewControllerAnimated:NO completion:nil];
        
    }
    else if (_mCurrentCallingCount == 2){
        if (!_mIsConference) {
            
            [self createConference];
            
        }
        else {
            
            [self closeConference];
            
            
        }
        [self setLineInfo];
    }
    
}

- (void)createConference
{
    
    _callTextImage.hidden = YES;
    _remoteBgImageView.hidden = YES;
    
    
    if (!_mIsConference) {
        
        _mIsConference = !_mIsConference;
        
        [self onCloseVideo];
        _localVideoView.hidden = YES;
        
        [shareAppDelegate.callManager createConference:_remoteVideoView videoWidth:352 videoHeight:288 displayLocalVideo:YES];
        
        if (_hasVideo) {
            
            [self callRemoteVideoView].hidden = NO;
            
            _callTextImage.hidden = YES;
            
            _logoTextImage.hidden = YES;
            
        }
        else
        {
            [self callRemoteVideoView].hidden = YES;
            
            _callTextImage.hidden = NO;
            
            _logoTextImage.hidden = NO;
            
        }
        
        _stateLabel.text = NSLocalizedString(@"Conference", @"Conference");
        
        [self refreshAppereance];
    }
    
}

- (void)closeConference
{
    
    
    _callTextImage.hidden = YES;
    _remoteBgImageView.hidden = YES;
    
    
    
    if (_mIsConference) {
        _mIsConference = !_mIsConference;
        _localVideoView.hidden = NO;
        //    _landscapeLocalVideoView.hidden = NO;
        [portSIPEngine setConferenceVideoWindow:nil];
        [self onOpenVideo];
        
        [shareAppDelegate.portSIPHandle removeFromConference:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId];
        //[shareAppDelegate destoryConference];
        [shareAppDelegate.callManager destoryConference];
        
        
        _stateLabel.text = @"";
        if (_hasVideo) {
            //          [self callRemoteVideoView].hidden = YES;
            //            _remoteBgImageView.hidden = NO;
            //           _callTextImage.hidden = NO;
            
            
        }
        [portSIPEngine setRemoteVideoWindow:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId remoteVideoWindow:_remoteVideoView];
        [self refreshAppereance];
        
        
        HSSession* otherSession = [shareAppDelegate.callManager findAnotherCall:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId];
        
        [shareAppDelegate.callManager holdCall:otherSession.sessionId onHold:YES];
        
        
    }
}

- (IBAction)onCameraButtonClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    //Front Camera
    if (btn.tag == 101) {
        _scrollVideoButton.tag = 1;
        [self onCloseVideo];
        [self setFrontCamera];
        [self onOpenVideo];
        
        if (!_mIsConference) {
            _localVideoView.hidden = NO;
        }
    }
    //Back Camera
    else if (btn.tag == 102){
        _scrollVideoButton.tag = 2;
        [self onCloseVideo];
        [self setBackCamera];
        [self onOpenVideo];
        
        if (!_mIsConference) {
            _localVideoView.hidden = NO;
            //            _landscapeLocalVideoView.hidden = NO;
        }
    }
    //None Camera
    else if (btn.tag == 103){
        _scrollVideoButton.tag = 3;
        [self setNoneCamera];
        
        //     [_scrollVideoButton setBackgroundColor:[UIColor clearColor]];
        _localVideoView.hidden = YES;
        //        _landscapeLocalVideoView.hidden = YES;
    }
    _cameraOptionView.tag = 0;
    [_cameraOptionView removeFromSuperview];
}

- (void)setFrontCamera
{
    if (_mCameraDeviceId == 1) {
        return;
    }
    [portSIPEngine setVideoDeviceId:1];
    _mCameraDeviceId = 1;
    [shareAppDelegate openAllSendVideo];
    
    _mLastOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
}

- (void)setBackCamera
{
    if (_mCameraDeviceId == 0) {
        return;
    }
    
    [portSIPEngine setVideoDeviceId:0];
    _mCameraDeviceId = 0;
    [shareAppDelegate openAllSendVideo];
    
    _mLastOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
}

- (void)setNoneCamera
{
    if (_mIsConference){
        [portSIPEngine setConferenceVideoWindow:nil];
        [shareAppDelegate closeAllSendVideo];
        return;
    }
    
    if (_hasVideo) {
        
#ifdef SDK_MIRROR
        [portSIPEngine displayLocalVideo:NO mirror:NO];
#else
        [portSIPEngine displayLocalVideo:NO];
#endif
        
        [portSIPEngine sendVideo:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId sendState:NO];
        [portSIPEngine setLocalVideoWindow:nil];
    }
    
    [_localVideoView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"user.png"]]];
}

- (void)onOpenVideo
{
    if (_mIsConference) {
        [portSIPEngine setConferenceVideoWindow:[self callRemoteVideoView]];
        return;
    }
    
    if (_hasVideo && _callState == CALL_STATE_INCALL) {
        
        [portSIPEngine setRemoteVideoWindow:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId remoteVideoWindow:[self callRemoteVideoView]];
        
        [portSIPEngine setLocalVideoWindow:[self callLocalVideoView]];
#ifdef SDK_MIRROR
        [portSIPEngine displayLocalVideo:YES mirror:NO];
#else
        [portSIPEngine displayLocalVideo:YES];
#endif
        [portSIPEngine sendVideo:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId sendState:YES];
        
    }
    
}

- (void)onCloseVideo
{
    if (_hasVideo) {
        
        [portSIPEngine setLocalVideoWindow:nil];
        
#ifdef SDK_MIRROR
        [portSIPEngine displayLocalVideo:NO mirror:NO];
#else
        [portSIPEngine displayLocalVideo:NO];
#endif
        if (  _mIsConference) {
            NSLog(@"_mIsConference =%d",_mIsConference);
            [portSIPEngine setRemoteVideoWindow:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId remoteVideoWindow:NULL];
            
        }
    }
    
}

- (void)exchangeVideoViewPosition
{
    if (_localVideoView.tag == 0) {
        _localVideoView.tag = 1;
        [portSIPEngine setRemoteVideoWindow:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId remoteVideoWindow:[self callLocalVideoView]];
        [portSIPEngine setLocalVideoWindow:[self callRemoteVideoView]];
    }
    else{
        _localVideoView.tag = 0;
        [portSIPEngine setRemoteVideoWindow:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId remoteVideoWindow:[self callRemoteVideoView]];
        [portSIPEngine setLocalVideoWindow:[self callLocalVideoView]];
    }
    
#ifdef SDK_MIRROR
    [portSIPEngine displayLocalVideo:YES mirror:NO];
#else
    [portSIPEngine displayLocalVideo:YES];
#endif
    [portSIPEngine sendVideo:[shareAppDelegate.callManager findCallByUUID:_sessionId].sessionId sendState:YES];
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:self.view];
    
    CGSize size = _localVideoView.bounds.size;
    if (point.x < size.width / 2) {
        point.x = size.width / 2 + 5;
    }
    
    if (point.x > self.view.bounds.size.width - size.width / 2) {
        point.x = self.view.bounds.size.width - size.width / 2 - 5;
    }
    
    if (point.y < size.height / 2) {
        point.y = size.height / 2 + 5;
    }
    
    if (point.y > self.view.bounds.size.height - size.height / 2) {
        point.y = self.view.bounds.size.height - size.height / 2 - 5;
    }
    
    _localVideoView.center = point;
}

- (void)handleTapGesture:(UITapGestureRecognizer*)gesture
{
    if (_dtmfView.tag == 1) {
        return ;
    }
    if (!_scrollBottomView.hidden && !_cameraOptionView.tag && !_dtmfView.tag) {
        _scrollBottomView.hidden = YES;
        _nameLabel.hidden = YES;
    }
    else{
        _scrollBottomView.hidden = NO;
        _nameLabel.hidden = NO;
        
        
        if (_hasVideo) {
            
            [hiddenTimer invalidate];
            hiddenTimer =nil;
            
            hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
                if (!_scrollBottomView.hidden && !_cameraOptionView.tag && !_dtmfView.tag) {
                    _scrollBottomView.hidden = YES;
                    _nameLabel.hidden = YES;
                }
                
            }];
        }
        
    }
}
- (void)showRecordImageTimer{
    
    _recordImageView.hidden = !_recordImageView.hidden;
    
}

- (void)onStartRecord2
{
    [_scrollRecordButton setSelected:YES];
    
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showRecordImageTimer) userInfo:nil repeats:YES];
    HSSession *session = [shareAppDelegate.callManager findCallByUUID:_sessionId];
    [shareAppDelegate onStartRecord:session.sessionId];
}


- (void)onStartRecord
{
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showRecordImageTimer) userInfo:nil repeats:YES];
    HSSession *session = [shareAppDelegate.callManager findCallByUUID:_sessionId];
    [shareAppDelegate onStartRecord:session.sessionId];
    
    [self.view bringSubviewToFront:_recordImageView];
    
}

- (void)onStopRecord
{
    _recordImageView.hidden = YES;
    
    if (_recordTimer != nil){
        //if reregister is start, remove it
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
    HSSession *session = [shareAppDelegate.callManager findCallByUUID:_sessionId];
    [shareAppDelegate onStopRecord:session.sessionId];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_dtmfView removeFromSuperview];
    [_cameraOptionView removeFromSuperview];
    
    _pageIndicator.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

#pragma mark Business logic

- (void)createCallWithId:(NSUUID*)uuid isCallOut:(BOOL)callOut byRemoteParty:(NSString *)remoteParty byDisplayName:(NSString *)displayName isVideo:(BOOL)video
{
    mRemoteVideoWidth =352; //default cif
    mRemoteVideoHeight = 288;
    _sessionId = uuid;
    _hasVideo = video;
    
    NSLog(@"video=========%d",video);
    
    NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval end = start;
    
    MediaType_t mediaType = MediaType_Audio;
    _remoteDisplayName = displayName;
    
    
    NSDictionary *dic = [contactView numbers2ContactsMapper];
    
    NSString *tempName =remoteParty;
    
    if ([remoteParty rangeOfString:@"@"] .location==NSNotFound) {
        tempName = [NSString stringWithFormat:@"%@@%@",remoteParty,shareAppDelegate.portSIPHandle.mAccount.SIPServer];
    }
    
    Contact *contact = [dic objectForKey:tempName];
    if (contact != nil) {
        _remoteDisplayName = contact.displayName;
    }
    
    _remotePartyName = remoteParty;
    int eventStatus = OUTGOING_SUCESS;
    if(callOut)
    {
#ifdef OEM_FIXEDHOST
        [self getCreditTime];
#endif
        if (video) {
            _callType = HSCallTypeOutCallVideo;
            mediaType = MediaType_AudioVideo;
        }
        else{
            _callType = HSCallTypeOutCallAudio;
        }
        _callState = CALL_STATE_OUTGOING;
    }
    else
    {
        eventStatus = INCOMING_SUCESS;
        if (video) {
            _callType = HSCallTypeInCallVideo;
            mediaType = MediaType_AudioVideo;
        }
        else{
            _callType = HSCallTypeInCallAudio;
        }
        _callState = CALL_STATE_INCOMING;
    }
    
    _history = [[History alloc] initWithName:0
                               byRemoteParty:remoteParty
                               byDisplayName:displayName
                                byLocalParty:shareAppDelegate.account.userName
                          byLocalDisplayname:shareAppDelegate.account.accountName
                                 byTimeStart:start
                                  byTimeStop:end
                                  byMediaype:mediaType
                                byCallStatus:eventStatus
                                   byContent:nil];
    
    
    
    if (!callOut) {
        [soundServiceEngine playRingTone];
    }
}

- (void)onInviteTrying
{
    [_callingStateLabel setText:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"Trying", @"Trying")]];
}
- (void)onInviteSessionProgress:(long)sessionId
               existsEarlyMedia:(BOOL)existsEarlyMedia
{
    _earlyMedia = existsEarlyMedia;
}

- (void)onInviteRinging
{
    _callingStateLabel.text = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Ringing", @"Ringing")];
    if (!_earlyMedia) {
        [soundServiceEngine playRingBackTone];
    }
}

- (void)onCallConnected
{
    [self.view.layer removeAllAnimations];
    [_circleScale.layer removeAllAnimations];
    
    _callState = CALL_STATE_INCALL;
    [soundServiceEngine stopRingBackTone];
    [soundServiceEngine stopRingTone];
    _history.mTimeStart = [[NSDate date] timeIntervalSince1970];
    
    if(self.isViewLoaded && self.view.window)
    {
        [self onBuildCallState];
    }
}

//- (void)onAnsweredCall:(BOOL)outgoingCall
- (void)onAnsweredCall:(BOOL)outgoingCall andvideo:(BOOL)isvideo
{
    
    _hasVideo = isvideo;
    
    [self onCallConnected];
    if(outgoingCall)
    {//Outgoing call, remote Answer call
        
    }
    else
    {//Incoming call, Local Answer Call
        if (databaseManage.mOptions.enableCallKit){
            //callkit answered call, show the call view
            NSLog(@"self=======%@",self);
            if (tabBarCtr.presentedViewController==nil) {
                
                [tabBarCtr presentViewController:self animated:NO completion:nil];
                
            }
        }
    }
}

//Invite Failure, show the reason
- (void)onInviteFailure:(NSString *)reason
{
    _stateLabel.text = [NSString stringWithFormat:@"%@", reason];
    _callingStateLabel.text = _stateLabel.text;
}

- (void)onRemoteHold
{
    _stateLabel.text = NSLocalizedString(@"Remote hold", @"Remote hold");
}

- (void)onRemoteUnHold
{
    _stateLabel.text = NSLocalizedString(@"Remote unHold", @"Remote unHold");
}

- (void)refreshAppereance
{
    _mCurrentCallingCount = [shareAppDelegate.callManager getConnectCallNum];
    
    if (_mCurrentCallingCount == 1) {
        [_scrollAddButton setImage:[UIImage imageNamed:@"call_add_call_ico"] forState:UIControlStateNormal];
    }
    else if (_mCurrentCallingCount == 2){
        if (!_mIsConference) {
            [_scrollAddButton setImage:[UIImage imageNamed:@"call_hebing_call_ico"] forState:UIControlStateNormal];
        }
        else{
            [_scrollAddButton setImage:[UIImage imageNamed:@"call_chaifen_call_ico"] forState:UIControlStateNormal];
        }
    }
}


- (void)updateMuteButton:(BOOL)muted
{
    _scrollMicoButton.selected = muted;
}

- (void)updateHoldButton:(BOOL)onHold
{
    _scrollHoldButton.selected = onHold;
}

-(void)updateAudioRouteButton:(int)routeType
{
    switch (routeType) {
        case 0:
            [_scrollLoudlyButton setImage:[UIImage imageNamed:@"call_speaker_ico_def"] forState:UIControlStateNormal];
            break;
        case 1:
            [_scrollLoudlyButton setImage:[UIImage imageNamed:@"call_speaker_pre"] forState:UIControlStateNormal];
            break;
        case 2:
            [_scrollLoudlyButton setImage:[UIImage imageNamed:@"call_bluetooth"] forState:UIControlStateNormal];
            break;
        case 3:
            [_scrollLoudlyButton setImage:[UIImage imageNamed:@"dtmf_sound_bluetooth.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}


#pragma mark - 横屏问题
- (BOOL)shouldAutorotateƒ
{
    if (_hasVideo && _callState == CALL_STATE_INCALL) {
        return YES;
        
    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (_hasVideo && _callState == CALL_STATE_INCALL) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}


CGRect getClientRect( BOOL isHorz)
{
    BOOL isStatusBarHidden = true;//顶部有没状态栏
    CGRect rcScreen = [[UIScreen mainScreen] bounds];//这个不会随着屏幕旋转而改变
    int status_height = isStatusBarHidden ? 0 :20;
    CGRect rcClient = rcScreen;
    if( isHorz)
    {
        rcClient.size.width -= status_height;
    }
    else
    {
        rcClient.size.height -= status_height;
    }
    CGRect rcArea = rcClient;
    if( isHorz )
    {
        rcArea.size.width = MAX(rcClient.size.width,rcClient.size.height);
        rcArea.size.height = MIN(rcClient.size.width,rcClient.size.height);
    }
    
    return rcArea;
}


#pragma mark


- (BOOL) shouldAutorotate {
    
    return YES;
}



-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    // best call super just in case
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    // will execute before rotation
    
    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        // will execute during rotation
        
        [self setFirstFrame];
        
        [self.view bringSubviewToFront:_scrollMicoButton];
        [self.view bringSubviewToFront:_scrollLoudlyButton];
        
        
        [_dtmfView removeFromSuperview];
        
        //  _scrollBottomView.hidden = NO;
        
    } completion:^(id  _Nonnull context) {
        // will execute after rotation
    }];
    
}

-(void)exchangeViewWidthHeight:(UIView*)view{
    CGRect rect = view.frame;
    rect.size.width = view.frame.size.height;
    rect.size.height = view.frame.size.width;
    
    [view setFrame:rect];
}

-(void)moveView:(UIView*)view posX:(int)x posY:(int)y{
    CGRect rect = view.frame;
    rect.origin.x = x;
    rect.origin.y = y;
    [view setFrame:rect];
    
    if(view == _localVideoView || view== _remoteVideoView){
        [(PortSIPVideoRenderView*)view updateVideoRenderFrame:view.bounds];
    }
}

-(int)getVideoOrotation:(UIInterfaceOrientation)orientation
{
    int currentVideoOrientationVal = 0;
    int lastVideoOrientationVal = 0;
    
    switch (_mLastOrientation) {
        case UIInterfaceOrientationPortrait:
            lastVideoOrientationVal = 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            lastVideoOrientationVal = 180;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            lastVideoOrientationVal = 90;
            break;
        case UIInterfaceOrientationLandscapeRight:
            lastVideoOrientationVal = 270;
            break;
        default:
            break;
    }
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            currentVideoOrientationVal = 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            currentVideoOrientationVal = 180;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            currentVideoOrientationVal = 90;
            break;
        case UIInterfaceOrientationLandscapeRight:
            currentVideoOrientationVal = 270;
            break;
        default:
            break;
    }
    
    if (_mCameraDeviceId == 1) {
        
        return (lastVideoOrientationVal + 360 - currentVideoOrientationVal)%360;
    }
    
    return (-lastVideoOrientationVal + 360 + currentVideoOrientationVal)%360;
}


-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    
    return UIInterfaceOrientationMaskAll;
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int newOutType = 0;
    
    switch (buttonIndex) {
        case 0://bluetooth
            newOutType = 2;
            break;
        case 1://iphone
            newOutType = 0;
            break;
        case 2://louder speaker
            newOutType = 1;
            break;
        default:
            newOutType = 3;
            break;
    }
    
    if(newOutType < 3)
    {
        [self updateAudioRouteButton:newOutType];
        [shareAppDelegate setAudioOutRoute:newOutType];
    }
    
}
- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    
}
@end
