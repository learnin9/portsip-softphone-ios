//
//  HSCallViewController.h
//  PortGo
//
//  Created by MrLee on 14-9-23.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constatnts.h"

typedef enum : NSUInteger {
    HSCallTypeOutCallAudio,
    HSCallTypeOutCallVideo,
    HSCallTypeInCallAudio,
    HSCallTypeInCallVideo,
} HSCallType;

@interface HSCallViewController : UIViewController

@property (nonatomic, assign) BOOL mIsConference;
@property (nonatomic, assign) HSCallType callType;
@property (nonatomic) CallState_t callState;
@property (nonatomic, copy) NSString *remoteDisplayName;
@property (nonatomic, copy) NSString *remotePartyName;
@property (nonatomic, copy) NSString *duration;

@property BOOL showcallview;




- (void)createCallWithId:(NSUUID*)uuid isCallOut:(BOOL)callOut byRemoteParty:(NSString *)remoteParty byDisplayName:(NSString *)displayName isVideo:(BOOL)video;

- (void)onInviteTrying;
- (void)onInviteSessionProgress:(long)sessionId
               existsEarlyMedia:(BOOL)existsEarlyMedia;
- (void)onInviteRinging;
- (void)onCallConnected;
//- (void)onAnsweredCall:(BOOL)outgoingCall;

- (void)onAnsweredCall:(BOOL)outgoingCall andvideo:(BOOL)isvideo;
- (void)onInviteFailure:(NSString *)reason;
- (void)onRemoteHold;
- (void)onRemoteUnHold;
- (void)refreshAppereance;

- (void)onOpenVideo;
- (void)onCloseVideo;

- (void)closeConference;

- (void)closeCall;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (IBAction)hangupCall:(id)sender;

- (void)updateMuteButton:(BOOL)muted;
- (void)updateHoldButton:(BOOL)onHold;
- (void)updateAudioRouteButton:(int)routeType;

- (void)onStartRecord;


@end
