//
//  AppDelegate.h
//  PortGo
//
//  Created by Joe Lepple on 3/25/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GlobalSetting.h"
#import "NumpadViewController.h"
#import "ContactViewController.h"
#import "RecentsViewController.h"
#import "SettingViewController.h"

#import "MessagesViewController.h"
#import "HSWebpageViewController.h"
#import "HSChatViewController.h"

#import "PortSIPHandle.h"
#import "SoundService.h"
#import "CallMananger.h"
#import "PortCxProvide.h"

#define SDK_MIRROR

#define kTabBarIndex_Contacts	0
#define kTabBarIndex_Recents	1
#define kTabBarIndex_Numpad	    2
#define kTabBarIndex_Messages   3
#define kTabBarIndex_Settings   4
#define kTabBarIndex_WebPage    5

#define shareAppDelegate      [AppDelegate sharedInstance]
#define portSIPEngine      [AppDelegate sharedInstance].portSIPHandle
#define soundServiceEngine [AppDelegate sharedInstance].soundService
#define chatView [AppDelegate sharedInstance].chatViewController
#define contactView [AppDelegate sharedInstance].contactViewController
#define recentView [AppDelegate sharedInstance].recentsViewController

#define setView [AppDelegate sharedInstance].settingsViewController

#define messageVIew [AppDelegate sharedInstance].messagesViewController


#define tabBarheight 49
#define tabBarCtr    ((UITabBarController*)shareAppDelegate.window.rootViewController)

#define IsBackgroundState ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground)

@class HSSession;
@class MLTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate,PortSIPEventDelegate, CallManagerDelegate,OptionOperatorDelegate>{
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) ContactViewController*    contactViewController;
@property (nonatomic, retain) RecentsViewController*    recentsViewController;
@property (nonatomic, retain) NumpadViewController*     numpadViewController;
@property (nonatomic, retain) MessagesViewController*   messagesViewController;
@property (nonatomic, retain) SettingViewController*    settingsViewController;
@property (nonatomic, retain) HSWebpageViewController*  webpageViewController;

@property (nonatomic, retain) HSChatViewController    *chatViewController;

@property (nonatomic, retain) SoundService* soundService;
@property (nonatomic, retain) PortSIPHandle* portSIPHandle;

@property (nonatomic, retain) Account *account;
@property (nonatomic, assign) NetworkStatus netStatus;
@property (nonatomic, retain) PortCxProvider* cxProvide;

//@property (nonatomic, retain) NSMutableArray *mSessionMArray;
@property (nonatomic, retain) CallManager* callManager;
@property     NSTimer * myTimer;
@property UIView * SmallView;
@property long svSessionID;
@property PortSIPVideoRenderView * SmallRemoteView;
@property PortSIPVideoRenderView * SmallLocalView;
@property UILabel * timeerlab;
@property int testindex;
@property int audioOutRouteType;

+(AppDelegate*) sharedInstance;


- (NSString*)getFullRemoteParty:(NSString*)remoteParty;
//- (NSString*)getUriUsername:(NSString*)uri;
- (NSString*)getShortRemoteParty:(NSString*)caller andCallee:(NSString*)callee;

- (long)makeCall:(NSString*)callee videoCall:(BOOL)videoCall;
- (void)endCall:(long)sessionId;

//CallManagerDelegate
- (void)onAnsweredCall:(long)sessionId;
- (void)onCloseCall:(long)sessionId;
- (void)onMuteCall:(long)sessionId muted:(BOOL)muted;
- (void)onHoldCall:(long)sessionId onHold:(BOOL)onHold;

-(void)onStopAudio;

- (void)onStartRecord:(long)sessionId;
- (void)onStopRecord:(long)sessionId;


- (void)onBackCall:(NSUUID*)uuid;
- (void)switchLineFrom:(long)sessionId;


- (void)setAudioOutRoute:(int)outType;
- (void)initTabbar;
- (int)registerWithAccount:(Account*)account;
- (void)startNotifierNetwork;
- (void)stopNotifierNetwork;
- (void)releaseResource;
- (void)refreshItemBadge;
- (void)closeAllSendVideo;
- (void)openAllSendVideo;
- (bool)pbxSuuportFileTransfer;
-(void)addPushSupportWithPortPBX:(BOOL)enablePush;

-(void)addremoteVideoView:(long)sessid andvideo:(BOOL)isvideo andTimeInterval:(NSTimeInterval)starttime;
-(void)deleteremoteVideoView;

-(void)settimelab:(NSString*)timeer;

@end
