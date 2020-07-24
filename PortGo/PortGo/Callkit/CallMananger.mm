//
//  CallMananger.m
//  PortGo
//
//  Created by portsip on 16/11/25.
//  Copyright © 2016 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CallKit/CallKit.h>
#import "CallMananger.h"
#import "PortCxProvide.h"
#import "AppDelegate.h"
#import "DataBaseManage.h"
#import "NSString+HSFilterString.h"

@implementation CXTransaction (PortCXTEX)

+ (CXTransaction *)transactionWithActions:(NSArray <CXAction *> *)actions {
    CXTransaction *transcation = [[CXTransaction alloc] init];
    for (CXAction *action in actions) {
        [transcation addAction:action];
    }
    return transcation;
}

@end

@implementation CallManager
{
    PortSIPSDK* _portSIPSDK;
    
    HSSession*     _sessionArray[MAX_LINES];
    
    DTMF_METHOD _playDTMFMethod;
    BOOL _playDTMFTone;
    
    NSUUID* _conferenceGroupID;
    
    CXCallController* _callController;
}

-(id _Nonnull)initWithSDK:(PortSIPSDK*)portsipSdk{
    if(self = [super init]){
        _portSIPSDK = portsipSdk;
        _isConference = false;
        
        _playDTMFMethod = DTMF_RFC2833;
        _playDTMFTone = YES;
        
        _conferenceGroupID = nil;
        
        _callController = [[CXCallController alloc] init];
        
        //Force disable CallKit
        //[self setEnableCallKit:databaseManage.mOptions.enableCallKit];
    }

    return self;
}


- (void)setEnableCallKit:(BOOL)enableCallKit {
    @synchronized(self) {
        [_portSIPSDK enableCallKit:enableCallKit];
    }
}

-(void)setPlayDTMFMethod:(DTMF_METHOD)dtmfMethod playDTMFTone:(BOOL)playDTMFTone
{
    _playDTMFMethod = dtmfMethod;
    _playDTMFTone = playDTMFTone;
}


#pragma mark - CallKit Manager
-(void)requestTransaction:(NSArray<CXAction *>*)actions
{
    [_callController requestTransaction:[CXTransaction transactionWithActions:actions] completion:^( NSError *_Nullable error){
        if (error !=nil) {
            for (CXAction *action in actions) {
                NSLog(@"Error requesting transaction, code:%d error:%@,action.uuid====%@", error.code, error.domain,action.UUID);
            }
            
        }else{
            NSLog(@"Requested transaction successfully");
        }
    }];
}

-(void)reportOutgoingCall:(NSUUID*)uuid number:(NSString*)number videoCall:(BOOL)video {
    CXHandle* handle=[[CXHandle alloc]initWithType:CXHandleTypeGeneric value:number];
    
    // Fallback on earlier versions
    
    CXStartCallAction* startCallAction = [[CXStartCallAction alloc] initWithCallUUID:uuid handle:handle];
    
    startCallAction.video = video;
    NSLog(@" reportOutgoingCall action.uuid====%@", startCallAction.callUUID );
    [self requestTransaction:@[startCallAction]];
}

-(void)reportInComingCall:(NSUUID*)uuid hasVideo:(BOOL)hasVideo from:(NSString*)from display:(NSString*)display completion:(PortCxProviderCompletion)completion {
    HSSession* result = [self findCallByUUID:uuid];
    if(result == nil)
        return;


    NSLog(@"reportInComingCall from====%@",from);
    
    NSString * tempFrom = from;
    
    
    if  ([from rangeOfString:@"@"].location !=NSNotFound){
        
        NSArray *strs = [from componentsSeparatedByString:@"@"];
        
        
        tempFrom = strs[0];
        
        
    }
    
    
//    CXHandle*handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:from];

 CXHandle*handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:tempFrom];
    
    
    CXCallUpdate* update = [[CXCallUpdate alloc] init];
    update.remoteHandle = handle;
    update.hasVideo = hasVideo;
    update.supportsGrouping = true;
    update.supportsDTMF = true;
    update.supportsUngrouping = true;
    
    NSLog(@" reportInComingCall action.uuid====%@", uuid);
    [[PortCxProvider sharedInstance].cxprovider reportNewIncomingCallWithUUID:uuid update:update completion:completion];
}

-(void)reportAnswerCall:(NSUUID*)uuid {
    HSSession* result = [self findCallByUUID:uuid];
    if(result == nil)
        return;
    CXAnswerCallAction* answerCallAction = [[CXAnswerCallAction alloc] initWithCallUUID:uuid];
    NSLog(@" reportAnswerCall action.uuid====%@", answerCallAction.callUUID);
    [self requestTransaction:@[answerCallAction]];
}

-(void)reportEndCall:(NSUUID*)uuid{
    HSSession* result = [self findCallByUUID:uuid];
    if(result == nil)
        return;
    CXEndCallAction* endCallAction = [[CXEndCallAction alloc] initWithCallUUID:result.uuid];
    NSLog(@" reportEndCall action.uuid====%@", endCallAction.callUUID);
    [self requestTransaction:@[endCallAction]];
}

-(void)reportSetHeldCall:(NSUUID*)uuid onHold:(BOOL)onHold{
    HSSession* result = [self findCallByUUID:uuid];
    
 
    if(result == nil)
        return;
    
    NSLog(@"setHeldCallActionsetHeldCallAction setHeldCallAction");
    
    CXSetHeldCallAction* setHeldCallAction = [[CXSetHeldCallAction alloc] initWithCallUUID:result.uuid onHold:onHold];
    
    [self requestTransaction:@[setHeldCallAction]];
}


-(void)reportSetMutedCall:(NSUUID*)uuid muted:(BOOL)muted {
    HSSession* result = [self findCallByUUID:uuid];
    if(result == nil)
        return;
    
    if(result.sessionState){
        CXSetMutedCallAction* setMutedCallAction = [[CXSetMutedCallAction alloc] initWithCallUUID:result.uuid muted:muted];
        [self requestTransaction:@[setMutedCallAction]];
    }
}

-(void)reportJoninConference:(NSUUID *)uuid{
    HSSession* result = [self findCallByUUID:uuid];
    if(result == nil || nil != _conferenceGroupID)
        return;
    
    CXSetGroupCallAction* setGroupCallAction = [[CXSetGroupCallAction alloc] initWithCallUUID:uuid callUUIDToGroupWith:_conferenceGroupID];
    
    [self requestTransaction:@[setGroupCallAction]];
}
-(void)reportUpdateCall:(NSUUID*)uuid hasVideo:(BOOL)hasVideo from:(NSString*)from {
    HSSession* result = [self findCallByUUID:uuid];
    if(result == nil)
        return;
    
    CXHandle*handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:from];
    CXCallUpdate* update = [[CXCallUpdate alloc] init];
    update.remoteHandle = handle;
    update.hasVideo = hasVideo;
    update.supportsGrouping = true;
    update.supportsDTMF = true;
    update.supportsUngrouping = true;
    update.localizedCallerName = from;
    NSLog(@" reportUpdateCall action.uuid====%@", uuid);
    [[PortCxProvider sharedInstance].cxprovider reportCallWithUUID:uuid updated:update];
}

-(void)reportRemoveFromConference:(NSUUID *)uuid{
    HSSession* result = [self findCallByUUID:uuid];
    if(result == nil || nil != _conferenceGroupID)
        return;
    
    CXSetGroupCallAction* setGroupCallAction = [[CXSetGroupCallAction alloc] initWithCallUUID:uuid callUUIDToGroupWith:nil];
    
    [self requestTransaction:@[setGroupCallAction]];
}

-(void)reportPlayDtmf:(NSUUID*)uuid tone:(int)tone{
    HSSession* result = [self findCallByUUID:uuid];
    NSString*digits;
    if (tone == 10) {
        digits = @"*";
    }
    else if (tone == 11)
    {
        digits = @"#";
    }
    else{
        digits = [NSString stringWithFormat:@"%d", tone];
    }
    if(result == nil)
        return;
    CXPlayDTMFCallAction* dtmfCallAction = [[CXPlayDTMFCallAction alloc] initWithCallUUID:result.uuid digits:digits type:CXPlayDTMFCallActionTypeSingleTone];
    
    [self requestTransaction:@[dtmfCallAction]];
}

#pragma mark - Call Manager interface
-(long)makeCall:(NSString*)callee displayName:(NSString* )displayName videoCall:(BOOL)videoCall
{
    int num = [self getConnectCallNum];
    if (num >= MAX_LINES) {
        return INVALID_SESSION_ID;
    }
    
    long sessionId = [self makeCallWithUUID:callee displayName:displayName videoCall:videoCall callUUID:[NSUUID new]];
    
    HSSession* session = [self findCallBySessionID:sessionId];

    if(session != nil && databaseManage.mOptions.enableCallKit)
    {
        [self reportOutgoingCall:session.uuid number:callee videoCall:videoCall];
        NSLog(@"reportOutgoingCall uuid =%@",session.uuid);
    }
    
    return sessionId;

}

//用于在收到incoming事件时，清除当前来电之前的无效session，比如已经被callkit拒绝并且标记，但是未被sdk实际处理的。
//在incoming事件中，此session还是无效，说明此无效session永远无法被sdk回调处理。所以在此主动清除。
-(void)clearInvalidateCall:(long)sessionId{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil&&_sessionArray[i].sessionId!=sessionId&&_sessionArray[i].callKitReject) {
            [self removeCall:_sessionArray[i]];
        }
    }
    
}

-(void)incomingCall:(long)sessionId
        existsVideo:(BOOL)existsVideo
        remoteParty:(NSString* _Nonnull)remoteParty
  remoteDisplayName:(NSString* _Nonnull)remoteDisplayName
           callUUID:(NSUUID*)uuid
withCompletionHandler:(void(^)(void))completion

{
    HSSession* session = [self findCallByUUID:uuid];
    NSLog(@"incomingCall sessionId = %d uuid====%@",sessionId,uuid);
//    HSSession* session = [self findCallBySessionID:sessionId];
    if(session){

        session.videoCall = existsVideo;
        if (databaseManage.mOptions.enableCallKit){
            
            if(session.sessionId<=INVALID_SESSION_ID)
            {//the call is answered by callKit, answer the call
                //[self startAudio];
                session.sessionId = sessionId;
                if(session.callKitAnswered){
                    BOOL bRet= [self answerCallWithUUID:session.uuid isVideo:existsVideo answerByCallKit:FALSE];
                    NSLog(@"incomingCall CallKit is answered call, do the answer now");
                    if (session.callKitCompletionCallback) {
                      session.callKitCompletionCallback(bRet);
                    }
                }
                
                if(session.callKitReject){
                    [self hungUpCallWithUUID:session.uuid processByCallkit:FALSE];
                    NSLog(@"incomingCall CallKit is Reject call, do the Reject now");
                }
            }
            [self reportUpdateCall:session.uuid hasVideo:existsVideo from:remoteParty];
        }else{
            
            NSLog(@"incomingCall sessionId = %d uuid====%@",sessionId,uuid);
            session.sessionId = sessionId;
        }
    }else{

        session = [[HSSession alloc] initWithSessionIdAndUUID:sessionId
                                                                callUUID:uuid
                                                             remoteParty:remoteParty
                                                             displayName:remoteDisplayName
                                                              videoState:existsVideo
                                                                 callOut:NO];
        
        if([self addCall:session] < 0){
            return;
        }
    
        NSLog(@"incomingCall remoteParty====%@",remoteParty);
        NSLog(@"incomingCall remoteDisplayName====%@",remoteDisplayName);
        
        if (databaseManage.mOptions.enableCallKit){
            
            [self reportInComingCall:session.uuid hasVideo:existsVideo from:remoteParty display:remoteDisplayName  completion:^( NSError *_Nullable error){
                if (error !=nil) {
                    [self hungUpCallWithUUID:session.uuid processByCallkit:TRUE];
                    NSLog(@"reportInComingCall completion: %@", error);
                }else{
                    if(session.outTimer.valid){
                        [session.outTimer invalidate];
                    }
                    if(session.sessionId<0){
                        NSDictionary *userInfo = @{@"uuid":uuid,@"sessionId":[NSNumber numberWithLong:session.sessionId]};
                        session.outTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(anwerCallTimeOut:) userInfo:userInfo repeats:NO];
                    }
                    NSLog(@"reportInComingCall completion");
                }
                if(completion)
                {
                    completion();
                }
            }];
        }
        else
        { // < iOS 10
            [_delegate onIncomingCallWithoutCallKit:sessionId existsVideo:existsVideo remoteParty:remoteParty remoteDisplayName:remoteDisplayName];
        }
    }
    if(session.sessionId>0){
        if([session.outTimer isValid]){
            [session.outTimer invalidate];
        }
    }

}

-(BOOL)answerCall:(long)sessionId isVideo:(BOOL)isVideo answerByCallKit:(BOOL)answerByCallKit{
    
    HSSession* session = [self findCallBySessionID:sessionId];
    if(session == nil)
    {
        NSLog(@"Not exist this SessionId = %ld", sessionId);
        return NO;
    }
    
    if (databaseManage.mOptions.enableCallKit)  {
         session.videoCall = isVideo;
        if(session.outgoing){
            session.sessionState = true;
        }
        [self reportAnswerCall:session.uuid];
        return YES;
    }else{
        return [self answerCallWithUUID:session.uuid isVideo:isVideo answerByCallKit:FALSE];
    }
}

-(void)endCall:(NSUUID*)uuid
{
    HSSession* session = [self findCallByUUID:uuid];
    if(session == nil)
        return;
    //callKitReject enableCallKit且callkit没有拒绝。
    if (databaseManage.mOptions.enableCallKit&&!session.callKitReject)  {
        [self reportEndCall:session.uuid];
    }else{
        [self hungUpCallWithUUID:session.uuid processByCallkit:FALSE];
    }
};

-(void)holdCall:(long)sessionId onHold:(BOOL)onHold
{
    HSSession* session = [self findCallBySessionID:sessionId];
    if(session == nil)
        return;
    
    if (!session.sessionState ||
        session.holdState == onHold)
    {//Call isn't connected, or hold isn't change
         
        return;
    }
    
    //[self holdCallWithUUID:session.uuid onHold:onHold];
    ///*
    if (databaseManage.mOptions.enableCallKit)  {
        
        NSLog(@"holdCall holdCall holdCall ");
        
        [self reportSetHeldCall:session.uuid onHold:onHold];
    }else{
        
        NSLog(@"holdCall2 holdCall2 holdCall2");
        
        
        [self holdCallWithUUID:session.uuid onHold:onHold];
    }//*/
}

-(void)holdAllCall:(BOOL)onHold
{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil &&
            _sessionArray[i].sessionState &&
            _sessionArray[i].holdState != onHold) {
            [self holdCall:_sessionArray[i].sessionId onHold:onHold];
        }
    }
}

-(void)muteCall:(long)sessionId muted:(BOOL)muted
{
    HSSession* session = [self findCallBySessionID:sessionId];
    if(session == nil)
        return;
    
    if (!session.sessionState)
    {//Call isn't connected
        return;
    }
    
    if (databaseManage.mOptions.enableCallKit)  {
        [self reportSetMutedCall:session.uuid muted:muted];
    }else{
        [self muteCallWithUUID:session.uuid muted:muted];
    }
}

-(void)muteAllCall:(BOOL)muted
{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil &&
            _sessionArray[i].sessionState) {
            [self muteCall:_sessionArray[i].sessionId muted:muted];
        }
    }
}

-(void)updateAllCall
{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil &&
            _sessionArray[i].sessionState) {
            [_portSIPSDK updateCall:_sessionArray[i].sessionId enableAudio:YES enableVideo:_sessionArray[i].videoCall];
        }
    }
}

-(void)playDtmf:(long)sessionId tone:(int)tone{
    HSSession* session = [self findCallBySessionID:sessionId];
    if(session == nil)
        return;
    
    if (!session.sessionState)
    {//Call isn't connected
        return;
    }
    
    [self playDTMFWithUUID:session.uuid dtmf:tone];

}

-(BOOL)createConference:(PortSIPVideoRenderView*) conferenceVideoWindow
                  videoWidth:(int) videoWidth
                 videoHeight:(int) videoHeight
           displayLocalVideo:(BOOL)displayLocalVideoInConference
{
    if (_isConference) {
        //has created conference;
        return NO;
    }
    
    int ret = 0;
    if(conferenceVideoWindow != nil &&
       videoWidth > 0 &&
       videoHeight > 0)
    {
        ret = [_portSIPSDK createVideoConference:conferenceVideoWindow videoWidth:videoWidth videoHeight:videoHeight displayLocalVideo:displayLocalVideoInConference];
    }
    else
    {
        ret = [_portSIPSDK createAudioConference];
    }
    
    if (ret != 0) {
        _isConference = NO;
        return NO;
    }
    
    _isConference = YES;
    _conferenceGroupID = [NSUUID UUID];
    
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil) {
            //Join all exist call to conference
            [self joinToConference:_sessionArray[i].sessionId];
        }
    }
    
    return YES;
}


-(void)joinToConference:(long)sessionId
{
    HSSession* session = [self findCallBySessionID:sessionId];
    if(session == nil)
        return;
    
    if (!session.sessionState)
    {//Call isn't connected
        return;
    }
    
    if (!_isConference)
    {//Conference not creaed
        return;
    }

    [self joinToConferenceWithUUID:session.uuid];

    if (databaseManage.mOptions.enableCallKit)  {
        if (session.holdState) {
             
            //unhold call before join confernce
       //     [self holdCall:session.sessionId onHold:NO];
            
            NSLog(@"reportSetHeldCall reportSetHeldCall reportSetHeldCall");
            
            [self reportSetHeldCall:session.uuid onHold:NO];
        }
        
        [self reportJoninConference:session.uuid];
    }else{
        if (session.holdState) {
            //unhold call before join confernce
            
            NSLog(@"holdCallWithUUID holdCallWithUUID holdCallWithUUID");
            
            [self holdCallWithUUID:session.uuid onHold:NO];
        }
        [self joinToConferenceWithUUID:session.uuid];
    }
}


-(void)removeFromConference:(long)sessionId
{
    HSSession* session = [self findCallBySessionID:sessionId];
    if(session == nil)
        return;
    
    if (!_isConference)
    {//Conference not creaed
        return;
    }
    
    if (databaseManage.mOptions.enableCallKit)  {
        [self reportRemoveFromConference:session.uuid];
    }else{
        [self removeFromConferenceWithUUID:session.uuid];
    }
 
}

-(void)destoryConference
{
    if (_isConference) {

        for (int i = 0; i < MAX_LINES; i++) {
            if (_sessionArray[i] != nil) {
                //Remove all exist call from conference
                [self removeFromConference:_sessionArray[i].sessionId];
            }
        }
        
        [_portSIPSDK destroyConference];
        _conferenceGroupID = nil;
        _isConference = false;
        NSLog(@"DestoryConference");
    }
}

#pragma mark - Call Manager implementation
-(long)makeCallWithUUID:(NSString*)callee displayName:(NSString*)displayName videoCall:(BOOL)videoCall callUUID:(NSUUID*)uuid
{
    HSSession* session = [self findCallByUUID:uuid];
    if(session)
    {//This is in APP outgoing call, has created session
        return session.sessionId;
    }
    
    int num = [self getConnectCallNum];
    if (num >= MAX_LINES) {
        return INVALID_SESSION_ID;
    }
    NSString *SIP_HEAD = @"(^(sip+(s)?+:))";
    NSString *SIP_TAIL = @"@([a-z0-9]+([\\.-][a-z0-9]+)*)+(:[0-9]{2,5})?$";

    long sessionId = [_portSIPSDK call:callee sendSdp:TRUE videoCall:videoCall];
    
    
    if (sessionId <= 0) {
        return sessionId;
    }
    
    if(displayName == nil)
    {
        displayName = callee;
    }
    
    session  = [[HSSession alloc] initWithSessionIdAndUUID:sessionId
                                                  callUUID:uuid
                                               remoteParty:callee
                                               displayName:displayName
                                                videoState:videoCall
                                                   callOut:YES];
    
    if([self addCall:session] < 0){
       [_portSIPSDK hangUp:session.sessionId];
       return -1;
   }

    [_delegate onNewOutgoingCall:sessionId];
    
    
    return session.sessionId;
    
}

-(BOOL)answerCallWithUUID:(NSUUID*)uuid isVideo:(BOOL)isVideo answerByCallKit:(BOOL)answerByCallKit;
{
    HSSession* sessionCall = [self findCallByUUID:uuid];
    NSLog(@"incomingcall answerCallWithUUID");
    if(sessionCall == nil)
        return NO;
    if(sessionCall.sessionId <= INVALID_SESSION_ID&&answerByCallKit){
        sessionCall.callKitAnswered = TRUE;
        
        
        if([sessionCall.outTimer isValid]){
            [sessionCall.outTimer invalidate];
        }
        
        NSDictionary *userInfo = @{@"uuid":uuid,@"sessionId":[NSNumber numberWithLong:sessionCall.sessionId]};
        sessionCall.outTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(anwerCallTimeOut:) userInfo:userInfo repeats:NO];
        
        
        NSLog(@"incomingcall fake answer session %ld ret=%@", sessionCall.sessionId,uuid.UUIDString);
        return YES;
    }
    
    NSLog(@"incomingcall real answer session %ld ret=%@", sessionCall.sessionId,uuid.UUIDString);
    if([sessionCall.outTimer isValid]){
        [sessionCall.outTimer invalidate];
        sessionCall.outTimer = nil;
    }
    int nRet = 0;
    if(!sessionCall.outgoing)
    {//Answer incoming Call
        nRet = [_portSIPSDK answerCall:sessionCall.sessionId videoCall:isVideo];
    }
    else
    {//outgoing call remote answer
        
    }
    if(nRet == 0)
    {
        sessionCall.sessionState = true;
        sessionCall.videoCall = isVideo;
        
        if(isVideo){
        }
        
        
        if (_isConference) {
            [self joinToConference:sessionCall.sessionId];
        }
        
        [_delegate onAnsweredCall:sessionCall.sessionId];
        NSLog(@"Answer Call on session %ld ", sessionCall.sessionId);

        return YES;
    }
    else
    {
        [_delegate onCloseCall:sessionCall.sessionId];
         NSLog(@"Answer Call on session %ld ! ret=%d", sessionCall.sessionId, nRet);
        return NO;
    }
}

 -(void)anwerCallTimeOut:(NSTimer *)timer{
    NSDictionary* userinfo = [timer userInfo];
    NSNumber* sessionid = [userinfo valueForKey:@"sessionId"];
    NSUUID* uuid =  [userinfo valueForKey:@"uuid"];

    [self endCall:uuid];
}

 -(void)hangupCallTimeOut:(NSTimer *)timer{
    NSDictionary* userinfo = [timer userInfo];
    NSNumber* sessionid = [userinfo valueForKey:@"sessionId"];
    NSUUID* uuid =  [userinfo valueForKey:@"uuid"];
    HSSession* session = [self findCallByUUID:uuid];
     if(session){
         
     }
}

-(void)hungUpCallWithUUID:(NSUUID*)uuid processByCallkit:(BOOL)callkitReject
{
    HSSession* sessionCall = [self findCallByUUID:uuid];
    if(sessionCall == nil)
    {
        return;
    }
    
    NSLog(@"incomingcall hungUpCallWithUUID ");
    if(sessionCall.sessionId <= INVALID_SESSION_ID&&callkitReject){
       sessionCall.callKitReject = TRUE;
       [_delegate onCloseCall:sessionCall.sessionId];
        NSLog(@"incomingcall fake reject session %ld ret=%@", sessionCall.sessionId,uuid.UUIDString);
       return;
    }
    
    NSLog(@"incomingcall real reject session %ld ret=%@", sessionCall.sessionId,uuid.UUIDString);
    if (_isConference) {
        [self removeFromConference:sessionCall.sessionId];
    }
    
    if (sessionCall.sessionState)
    {//Incoming/Outgoing Call is connected, fire by hangupCall or onInviteClosed
        [_portSIPSDK hangUp:sessionCall.sessionId];
        if (sessionCall.videoCall) {
        }
        NSLog(@"Hungup call on session %ld", sessionCall.sessionId);
    }
    else if (sessionCall.outgoing)
    {//Outgoing call, fire by onInviteFailure
         [_portSIPSDK hangUp:sessionCall.sessionId];
        NSLog(@"Invite call Failure on session %ld", sessionCall.sessionId);
    }
    else
    {//Incoming call, reject call by user.
        [_portSIPSDK rejectCall:sessionCall.sessionId code:486];
        NSLog(@"Rejected call on session %ld", sessionCall.sessionId);
    }
    
    [_delegate onCloseCall:sessionCall.sessionId];
}


-(void)holdCallWithUUID:(NSUUID*)uuid onHold:(BOOL)onHold
{
    HSSession* session = [self findCallByUUID:uuid];
    if(session == nil){
        return;
    }
    
    NSLog(@"holdCallWithUUID =%d",onHold);
    
//    if (!session.sessionState ||
//        session.holdState == onHold)
//    {//Call isn't connected, or hold isn't change
//
//        NSLog(@"session.holdState == onHold");
//
//        return;
//    }
    
    if(onHold)
    {
        [_portSIPSDK hold:session.sessionId];
        session.holdState = true;
        NSLog(@"Hold call on session: %ld", session.sessionId);
    }
    else{
        [_portSIPSDK unHold:session.sessionId];
        session.holdState = false;
        NSLog(@"UnHold call on session: %ld", session.sessionId);
    }
    [_delegate onHoldCall:session.sessionId onHold:onHold];
}

-(void)muteCallWithUUID:(NSUUID*)uuid muted:(BOOL)muted
{
    HSSession* session = [self findCallByUUID:uuid];
    if(session == nil)
        return;
    if(session.sessionState){
        if(muted)
        {//mute Microphone and video
            [_portSIPSDK muteSession:session.sessionId
                   muteIncomingAudio:false
                   muteOutgoingAudio:true
                   muteIncomingVideo:false
                   muteOutgoingVideo:true];
        }
        else
        {//unmute Microphone and video
            [_portSIPSDK muteSession:session.sessionId
                   muteIncomingAudio:false
                   muteOutgoingAudio:false
                   muteIncomingVideo:false
                   muteOutgoingVideo:false];
        }
        
        [_delegate onMuteCall:session.sessionId muted:muted];
    }
}

-(void)playDTMFWithUUID:(NSUUID*)uuid dtmf:(int)dtmf
{
    HSSession* result = [self findCallByUUID:uuid];
    if(result == nil)
        return;
    
    if(result.sessionState)
    {
        [_portSIPSDK sendDtmf:result.sessionId dtmfMethod:_playDTMFMethod code:dtmf dtmfDration:160 playDtmfTone:_playDTMFTone];
    }
}



-(void)joinToConferenceWithUUID:(NSUUID*)uuid
{
    HSSession* session = [self findCallByUUID:uuid];
    if(session == nil)
        return;
    
   
    if (_isConference) {
        
        if (session.sessionState) {
            if (session.holdState) {
                [self holdCall:session.sessionId onHold:NO];

                //[_portSIPSDK unHold:session.sessionId];
                
                NSLog(@"joinToConferenceWithUUID joinToConferenceWithUUID joinToConferenceWithUUID");
                
                session.holdState = false;
            }
            
            [_portSIPSDK joinToConference:session.sessionId];
        }
    }
}

-(void)removeFromConferenceWithUUID:(NSUUID*)uuid
{
    HSSession* session = [self findCallByUUID:uuid];
    if(session == nil)
        return;
    
    
    if (_isConference) {
        [_portSIPSDK removeFromConference:session.sessionId];
    }
}

#pragma mark - Session Array Controller
-(HSSession*)findAnotherCall:(long)sessionID
{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil &&
            _sessionArray[i].sessionId != sessionID) {
            return _sessionArray[i];
        }
    }
    
    return nil;
}

-(HSSession*)findAnotherCallByUUID:(NSUUID*)uuid
{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil &&(uuid==nil||![_sessionArray[i].uuid.UUIDString isEqual:uuid.UUIDString])) {
            return _sessionArray[i];
        }
    }
    
    return nil;
}


#pragma mark - Session Array Controller
-(HSSession*)getProccessingCall
{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil &&
            _sessionArray[i].sessionId>0&&
            !_sessionArray[i].sessionState&&
            !_sessionArray[i].outgoing) {
            return _sessionArray[i];
        }
    }
    
    return nil;
}

-(HSSession*)findCallBySessionID:(long)sessionID
{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil &&
            _sessionArray[i].sessionId == sessionID) {
            return _sessionArray[i];
        }
    }
    return nil;
}

-(HSSession*)findCallByOrignalSessionID:(long)orignalId
{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil &&
            _sessionArray[i].sessionId == orignalId) {
            return _sessionArray[i];
        }
    }
    return nil;
}

-(int)getHSSessionIndex:(HSSession*)session{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil &&
            _sessionArray[i] == session) {
            return i;
        }
    }
    
    return -1;
}

-(HSSession*)findCallByUUID:(NSUUID*)uuid{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil &&
            [_sessionArray[i].uuid.UUIDString isEqual:uuid.UUIDString]) {
            return _sessionArray[i];
        }
    }
    return nil;
}

-(HSSession*)findCallByIndex:(int)index{
    if(0<=index && index< MAX_LINES)
    {
        return _sessionArray[index];
    }
    return nil;
}

-(int) findIndexBySessionID:(long)sessionID
{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil &&
            _sessionArray[i].sessionId == sessionID) {
            return i;
        }
    }
    return -1;
};

-(int)addCall:(HSSession*)call{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] == nil || _sessionArray[i].callKitReject) {
            _sessionArray[i] = call;
            return i;
        }
    }
    
    return -1;
}

-(void)removeCall:(HSSession*)call{
    
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] == call) {
            if([call.outTimer isValid]){
                [call.outTimer invalidate];
            }
            call.outTimer = nil;
            _sessionArray[i] = nil;
        }
    }
}

-(void)clear{
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil) {
            [self endCall:_sessionArray[i].uuid];
//            [_portSIPSDK hangUp:_sessionArray[i].sessionId];
            if([_sessionArray[i].outTimer isValid]){
                [_sessionArray[i].outTimer invalidate];
            }
            _sessionArray[i].outTimer = nil;
            
            _sessionArray[i] = nil;
        }
    }
}

-(int)getConnectCallNum{
    int num=0;
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil&&_sessionArray[i].sessionId>INVALID_SESSION_ID) {
            num++;
        }
    }
    
    return num;
}

-(int)getCallNum{
    int num=0;
    for (int i = 0; i < MAX_LINES; i++) {
        if (_sessionArray[i] != nil) {
            num++;
        }
    }
    
    return num;
}

#pragma mark - Audio Controller


-(void)startAudio
{
    NSLog(@"_portSIPSDK startAudio");
    [_portSIPSDK startAudio];
}

-(void)stopAudio
{
    NSLog(@"_portSIPSDK stopAudio");
    [_portSIPSDK stopAudio];
    
    [_delegate onStopAudio];
}

@end
