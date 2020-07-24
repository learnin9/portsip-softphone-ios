//
//  CallMananger.h
//
//
//  Created by portsip on 16/11/25.
//  Copyright © 2006-2017 PortSIP Solutions Inc. All rights reserved.
//

#ifndef CallMananger_h
#define CallMananger_h
#include "HSSession.h"
#import <CallKit/CallKit.h>
#import <PortSIPUCSDK/PortSIPUCSDK.h>
@protocol CallManagerDelegate <NSObject>
@required
- (void)onIncomingCallWithoutCallKit:(long)sessionId
                       existsVideo:(BOOL)existsVideo
                       remoteParty:(NSString* _Nonnull)remoteParty
                   remoteDisplayName:(NSString* _Nonnull)remoteDisplayName;

- (void)onNewOutgoingCall:(long)sessionId;
- (void)onAnsweredCall:(long)sessionId;
- (void)onCloseCall:(long)sessionId;

-(void)onMuteCall:(long)sessionId muted:(BOOL)muted;
-(void)onHoldCall:(long)sessionId onHold:(BOOL)onHold;

-(void)onStopAudio;
@end


@interface CallManager:NSObject
@property (nonatomic, weak, nullable) id <CallManagerDelegate> delegate;
@property   BOOL isConference;

typedef void(^PortCxProviderCompletion)(NSError * _Nullable error);

-(id _Nonnull)initWithSDK:(PortSIPSDK*_Nonnull)portsipSdk;

-(void)setPlayDTMFMethod:(DTMF_METHOD)dtmfMethod playDTMFTone:(BOOL)playDTMFTone;
-(long)makeCall:(NSString* _Nonnull)callee displayName:(NSString* _Nullable)displayName  videoCall:(BOOL)videoCall;
-(void)incomingCall:(long)sessionId
        existsVideo:(BOOL)existsVideo
        remoteParty:(NSString* _Nonnull)remoteParty
  remoteDisplayName:(NSString* _Nonnull)remoteDisplayName
           callUUID:(NSUUID*)uuid
withCompletionHandler:(void(^)(void))completion;

-(BOOL)answerCall:(long)sessionId isVideo:(BOOL)isVideo answerByCallKit:(BOOL)answerByCallKit;
-(void)endCall:(NSUUID*)uuid;
-(void)holdCall:(long)sessionId onHold:(BOOL)onHold;
-(void)holdAllCall:(BOOL)onHold;
-(void)muteCall:(long)sessionId muted:(BOOL)muted;
-(void)muteAllCall:(BOOL)muted;
-(void)updateAllCall;
-(void)playDtmf:(long)sessionId tone:(int)tone;

-(BOOL)createConference:(PortSIPVideoRenderView* _Nullable) conferenceVideoWindow
             videoWidth:(int) videoWidth
            videoHeight:(int) videoHeight
      displayLocalVideo:(BOOL)displayLocalVideoInConference;
-(void)joinToConference:(long)sessionId;
-(void)removeFromConference:(long)sessionId;
-(void)destoryConference;

//
- (void)setEnableCallKit:(BOOL)enableCallKit;
-(long)makeCallWithUUID:(NSString* _Nonnull)callee
                              displayName:(NSString* _Nullable)displayName
                              videoCall:(BOOL)videoCall
                               callUUID:(NSUUID*_Nullable)uuid;
-(void)hungUpCallWithUUID:(NSUUID* _Nonnull)uuid processByCallkit:(BOOL)callkitReject;
-(void)holdCallWithUUID:(NSUUID* _Nonnull)uuid onHold:(BOOL)onHold;
-(void)muteCallWithUUID:(NSUUID* _Nonnull)uuid muted:(BOOL)muted;
-(void)playDTMFWithUUID:(NSUUID* _Nonnull)uuid dtmf:(int)dtmf;
-(BOOL)answerCallWithUUID:(NSUUID* _Nonnull)uuid isVideo:(BOOL)isVideo answerByCallKit:(BOOL)answerByCallKit;
-(void)joinToConferenceWithUUID:(NSUUID* _Nonnull)uuid;
-(void)removeFromConferenceWithUUID:(NSUUID* _Nonnull)uuid;

-(void)startAudio;
-(void)stopAudio;

-(HSSession*)findAnotherCallByUUID:(NSUUID*)uuid;
-(HSSession* _Nullable)findAnotherCall:(long)sessionID;//
-(HSSession* _Nullable) findCallBySessionID:(long)sessionID;
-(HSSession* _Nullable) findCallByOrignalSessionID:(long)orignalId;
-(HSSession* _Nullable) findCallByUUID:(NSUUID*_Nonnull)uuid;
-(HSSession* _Nullable)findCallByIndex:(int)index;
-(HSSession* _Nullable)getProccessingCall;
-(int) findIndexBySessionID:(long)sessionID;
-(int)getHSSessionIndex:(HSSession* _Nonnull)session;

-(int)addCall:(HSSession* _Nonnull)call;
-(void)removeCall:(HSSession* _Nonnull)call;

-(void)clearInvalidateCall:(long)sessionId;
-(void)clear;
-(int)getConnectCallNum;
-(int)getCallNum;

@end
#endif /* CallMananger_h */
