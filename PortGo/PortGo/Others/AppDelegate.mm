//
//  AppDelegate.m
//  PortGo
//
//  Created by Joe Lepple on 3/25/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "HSSession.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HSCallViewController.h"
#import "NSString+HSFilterString.h"
#import "HSCallViewController.h"
#import "MLTabBarController.h"
#import <Intents/Intents.h>
#import "HSKeepAwake.h"
#import "UIColor_Hex.h"
#import <Contacts/Contacts.h>
#import "PortSipSignalHandler.h"

#import "JRDB.h"
#import "callListModel.h"

#import "addFriendModel.h"

#import "IQKeyboardManager.h"
#import <PushKit/PushKit.h>

#import <StoreKit/StoreKit.h>

//#import <Bugly/Bugly.h>

#import "portsipPushModel.h"

#import "HSLoginViewController.h"

#import "Toast+UIView.h"
#import "HttpHelper.h"
#import <UserNotifications/UserNotifications.h>

#define kNotifKey @"key"
#define kNotifKey_IncomingCall @"icall"
#define kNotifKey_MissCall @"icallmiss"
#define kNotifKey_IncomingMsg @"imsg"
#define kNotifIncomingCall_SessionId @"sid"
#define kNotifIncomingCall_ExistsVideo @"existsVideo"
#define kNotifIncomingCall_RemoteParty @"remoteParty"
#define kNotifIncomingCall_RemoteDispalyName @"remoteDisplayName"
#define kNotifIncomingCall_StartTime @"StartTime"

#define kDelayShowSec 3

@interface AppDelegate () <
UITabBarControllerDelegate, UIAlertViewDelegate, PKPushRegistryDelegate,
UNUserNotificationCenterDelegate, SKPaymentTransactionObserver,
SKProductsRequestDelegate, OffLineMessageDelegate> {
    BOOL _mConferenceState;
    
    Reachability *internetReach;
    
    HSKeepAwake *_mKeepAwake;
    NSUInteger _mTabBarSelectedItem;
    
    long mysessionId;
    
    NSString *_VoIPPushToken;
    NSString *_APNsPushToken; // for message
    BOOL _IsPortPBX;
    BOOL _PBXSupportFile;
    UIBackgroundTaskIdentifier _backtaskIdentifier;
    
    BOOL ExistingSystemDialing;
    
    NSString *SystemDialingNum;
    
    BOOL SystemDialingVideo;
}

@end

@implementation AppDelegate

#pragma mark -
#pragma mark

- (bool)pbxSuuportFileTransfer {
    return _PBXSupportFile;
}

- (void)saveHistory:(NSString *)remoteParty
  remoteDisplayName:(NSString *)remoteDisplayName
        existsVideo:(BOOL)existsVideo {
    NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval end = start;
    int mediaType = MediaType_Audio;
    if (existsVideo) {
        mediaType = MediaType_AudioVideo;
    }
    
    if ([remoteParty rangeOfString:@"@"].location == NSNotFound) {
        
        remoteParty = [NSString
                       stringWithFormat:@"%@@%@", remoteParty,
                       shareAppDelegate.portSIPHandle.mAccount.userDomain];
    }
    
    History *history = [[History alloc] initWithName:0
                                       byRemoteParty:remoteParty
                                       byDisplayName:remoteDisplayName
                                        byLocalParty:_account.userName
                                  byLocalDisplayname:_account.displayName
                                         byTimeStart:start
                                          byTimeStop:end
                                          byMediaype:mediaType
                                        byCallStatus:INCOMING_FAILED
                                           byContent:nil];
    
    [databaseManage insertHistory:history];
    [recentView addNewHistroy:history];
}

- (NSString *)getFullRemoteParty:(NSString *)remoteParty {
    Account *mAccount = [portSIPEngine mAccount];
    NSString *remoteFullParty = remoteParty;
    if ([remoteFullParty rangeOfString:@"@"].location == NSNotFound) {
        if (mAccount.userDomain.length > 0) {
            remoteFullParty = [NSString
                               stringWithFormat:@"%@@%@", remoteParty, mAccount.userDomain];
        } else {
            remoteFullParty =
            [NSString stringWithFormat:@"%@@%@", remoteParty, mAccount.userDomain];
        }
    }
    
    return remoteFullParty;
}

- (NSString *)getShortRemoteParty:(NSString *)caller
                        andCallee:(NSString *)callee {
    NSString *remoteParty = caller; //[[NSString alloc] initWithCString:(const
    // char*)caller encoding:NSUTF8StringEncoding];
    NSString *localParty = callee; //[[NSString alloc] initWithCString:(const
    // char*)callee encoding:NSUTF8StringEncoding];
    
    // remove remote party "sip:", From sip:x@y:Port to x@y:Port
    if ([remoteParty hasPrefix:@"SIP:"] || [remoteParty hasPrefix:@"sip:"]) {
        remoteParty = [remoteParty substringFromIndex:4];
    } // remove local party "sip:"
    if ([localParty hasPrefix:@"SIP:"] || [localParty hasPrefix:@"sip:"]) {
        localParty = [localParty substringFromIndex:4];
    }
    
    // if has port ,remove it. From x@y:Port to x@y
    NSArray *separatByPort = [remoteParty componentsSeparatedByString:@":"];
    remoteParty = [separatByPort objectAtIndex:0];
    
    separatByPort = [localParty componentsSeparatedByString:@":"];
    localParty = [separatByPort objectAtIndex:0];
    
    return remoteParty;
}

#pragma mark - PortSIPSDK sip callback events Delegate
- (void)onRegisterSuccess:(char *)statusText
               statusCode:(int)statusCode
               sipMessage:(char *)sipMessage {
    if (databaseManage.mOptions.enableForward) {
        [portSIPEngine enableCallForward:NO
                               forwardTo:databaseManage.mOptions.forwardTo];
    }
    
    [_portSIPHandle onRegisterSuccess:statusCode withStatusText:statusText];
    
    NSString *message = [[NSString alloc] initWithCString:(const char *)sipMessage
                                                 encoding:NSASCIIStringEncoding];
    NSString *userAgent = [_portSIPHandle getSipMessageHeaderValue:message
                                                        headerName:@"User-Agent"];
    
    [httpHelper offlineMessage:self.account];
    NSString *xppush =
    [_portSIPHandle getSipMessageHeaderValue:message headerName:@"x-p-push"];
    
    NSLog(@"pushxxxx userAgent= %@,xppush =%@", userAgent, xppush);
    
    if (xppush != nil) {
        _PBXSupportFile = YES;
    } else {
        _PBXSupportFile = NO;
    }
    if ([userAgent containsString:@"PortSIP PBX"] ||
        xppush != nil)// this is a PortSIP PBX, support
    {
        _IsPortPBX = YES;
    } else {
        _IsPortPBX = NO;
    }
    
    if (!_IsPortPBX &&
        [self.callManager getConnectCallNum] >
        0) { // have active call, and server not PortPBX, update call
        [self.callManager updateAllCall];
    }
    
    if (ExistingSystemDialing && _IsPortPBX) {
        
        [self makeCall:SystemDialingNum videoCall:SystemDialingVideo];
        
        ExistingSystemDialing = NO;
    }
};

- (void)onRegisterFailure:(char *)statusText
               statusCode:(int)statusCode
               sipMessage:(char *)sipMessage {
    
    [_portSIPHandle onRegisterFailure:statusCode withStatusText:statusText];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTimer"
                                                        object:nil];
    [self.callManager clear];
};

#pragma mark--
#pragma mark
- (void)onInviteIncoming:(long)sessionId
       callerDisplayName:(char *)callerDisplayName
                  caller:(char *)caller
       calleeDisplayName:(char *)calleeDisplayName
                  callee:(char *)callee
             audioCodecs:(char *)audioCodecs
             videoCodecs:(char *)videoCodecs
             existsAudio:(BOOL)existsAudio
             existsVideo:(BOOL)existsVideo
              sipMessage:(char *)sipMessage {
    [_mKeepAwake stopKeepAwake];
    [_portSIPHandle onRegisterSuccess:200 withStatusText:(char*)[@"" cStringUsingEncoding:kCFStringEncodingUTF8]];
    
    [self initTabbar];
    NSString *strCaller = [[NSString alloc] initWithCString:(const char *)caller
                                                   encoding:NSUTF8StringEncoding];
    NSString *strCallee = [[NSString alloc] initWithCString:(const char *)callee
                                                   encoding:NSUTF8StringEncoding];
    NSString *remoteParty =
    [self getShortRemoteParty:strCaller andCallee:strCallee];
    NSString *remoteDisplayName =
    [[NSString alloc] initWithCString:(const char *)callerDisplayName
                             encoding:NSUTF8StringEncoding];
    
    if ([remoteDisplayName length] == 0) {
        remoteDisplayName = [remoteParty getUriUsername:remoteParty];
    }
    
    NSUUID *uuid = nil;
    if (databaseManage.mOptions.enableCallKit) {
        NSString *message =
        [[NSString alloc] initWithCString:(const char *)sipMessage
                                 encoding:NSASCIIStringEncoding];
        NSString *headerName = @"x-push-id";
        
        NSString *pushId =
        [_portSIPHandle getSipMessageHeaderValue:message headerName:headerName];
        if (pushId != nil) {
            //[NSThread sleepForTimeInterval:3.0];
            uuid = [[NSUUID alloc] initWithUUIDString:pushId];
            NSLog(@"onInviteIncoming uuid: %@", uuid);
        }
    }
    
    if (uuid == nil) {
        uuid = [NSUUID new];
    }
    //    Contact *contact = [contactView getContactByPhoneNumber:remoteParty];
    NSDictionary *dic = [contactView numbers2ContactsMapper];
    Contact *contact = [dic objectForKey:remoteParty];
    if (contact != nil) {
        remoteDisplayName = contact.displayName;
        
        NSLog(@"displayName in ===%@", contact.displayName);
    }
    
    int num = [self.callManager getCallNum];
    if (num >= 2) {
        //        [self.callManager ]
        [_portSIPHandle rejectCall:sessionId code:486];
        [self saveHistory:remoteParty
        remoteDisplayName:remoteDisplayName
              existsVideo:existsVideo];
        return;
    }
    
    if (num == 1) {
        // has a exist session, dismiss this session
        HSSession *oldSession = [self.callManager findCallByIndex:0];
        if (oldSession && ![oldSession.uuid.UUIDString isEqual:uuid.UUIDString]) {
            [oldSession.callViewController dismissViewControllerAnimated:NO
                                                              completion:nil];
        }
    }
    
    [self.callManager clearInvalidateCall:sessionId];
    [self.callManager incomingCall:sessionId
                       existsVideo:existsVideo
                       remoteParty:remoteParty
                 remoteDisplayName:remoteDisplayName
                          callUUID:uuid
             withCompletionHandler:nil];
    
    NSString *callforwardindex =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"callforwardindex"];
    
    // NSLog(@"callforwardindex===============%@",callforwardindex);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InviteEvent" object:nil];
    
    if ([callforwardindex isEqualToString:@"1"] ||
        [callforwardindex isEqualToString:@"2"]) {
        [portSIPEngine hangUp:mysessionId];
    }
    
    if ([callforwardindex isEqualToString:@"3"]) {
        mysessionId = sessionId;
        
        float callforwardtime = [[[NSUserDefaults standardUserDefaults]
                                  objectForKey:@"callforwardtime"] floatValue];
        
        if (callforwardtime < 0.9) {
            
            callforwardtime = 3;
        }
        
        shareAppDelegate.myTimer =
        [NSTimer scheduledTimerWithTimeInterval:callforwardtime
                                         target:self
                                       selector:@selector(scrollTimer)
                                       userInfo:nil
                                        repeats:NO];
    }
};

- (void)scrollTimer {
    
    NSString *callforwardobject =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"callforwardobject"];
    
    [portSIPEngine forwardCall:mysessionId forwardTo:callforwardobject];
    [portSIPEngine hangUp:mysessionId];
    
    [self endCall:mysessionId];
}

- (void)onInviteTrying:(long)sessionId {
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    
    if (session != nil) {
        [session.callViewController onInviteTrying];
    }
};

- (void)onInviteSessionProgress:(long)sessionId
                    audioCodecs:(char *)audioCodecs
                    videoCodecs:(char *)videoCodecs
               existsEarlyMedia:(BOOL)existsEarlyMedia
                    existsAudio:(BOOL)existsAudio
                    existsVideo:(BOOL)existsVideo
                     sipMessage:(char *)sipMessage {
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    
    if (session != nil) {
        [session.callViewController onInviteSessionProgress:sessionId
                                           existsEarlyMedia:existsEarlyMedia];
    }
}

- (void)onInviteRinging:(long)sessionId
             statusText:(char *)statusText
             statusCode:(int)statusCode
             sipMessage:(char *)sipMessage {
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    
    if (session != nil) {
        [session.callViewController onInviteRinging];
    }
};

- (void)onInviteAnswered:(long)sessionId
       callerDisplayName:(char *)callerDisplayName
                  caller:(char *)caller
       calleeDisplayName:(char *)calleeDisplayName
                  callee:(char *)callee
             audioCodecs:(char *)audioCodecs
             videoCodecs:(char *)videoCodecs
             existsAudio:(BOOL)existsAudio
             existsVideo:(BOOL)existsVideo
              sipMessage:(char *)sipMessage;
{
    
    [self.callManager answerCall:sessionId isVideo:existsVideo answerByCallKit:FALSE];
}

- (void)delayEndCall:(HSSession *)session {
    [self endCall:session.sessionId];
}

- (void)onInviteFailure:(long)sessionId
                 reason:(char *)reason
                   code:(int)code
             sipMessage:(char *)sipMessage {
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    
    if (session != nil) {
        NSString *strReason = [[NSString alloc] initWithUTF8String:reason];
        [session.callViewController
         onInviteFailure:NSLocalizedString(strReason, strReason)];
        
        [self performSelector:@selector(delayEndCall:)
                   withObject:session
                   afterDelay:3];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InviteEvent" object:nil];
}

- (void)onInviteUpdated:(long)sessionId
            audioCodecs:(char *)audioCodecs
            videoCodecs:(char *)videoCodecs
            existsAudio:(BOOL)existsAudio
            existsVideo:(BOOL)existsVideo
             sipMessage:(char *)sipMessage {
    
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    if (session != nil) {
        NSString *onvideo = [NSString stringWithFormat:@"%d", existsVideo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onInviteUpdated"
                                                            object:onvideo];
        
        if (existsAudio) {
        }
    }
};

- (void)onInviteConnected:(long)sessionId {
    HSSession* session =  [self.callManager findCallBySessionID:sessionId];//处理代接功能，代接，是一个呼出通话，但不会走oninviteanswered
    if(session!=nil&&session.sessionId>0&&session.outgoing&&!session.sessionState){
        [self.callManager answerCall:sessionId isVideo:session.videoCall answerByCallKit:FALSE];
    }

    BOOL Enalbe_Call_Record =
    [[NSUserDefaults standardUserDefaults] boolForKey:@"Enalbe_Call_Record"];
    
    if (Enalbe_Call_Record) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"Enalbe_Call_Record"
         object:nil];
    }
    
    [shareAppDelegate.myTimer invalidate];
    
    shareAppDelegate.myTimer = nil;
}

- (void)onInviteBeginingForward:(char *)forwardTo {
}

- (void)onRemoteHold:(long)sessionId {
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    if (session != nil) {
        [session.callViewController onRemoteHold];
    }
};

-(void)refreshMissCall:(HSSession*)session{
    BOOL isMissCall = NO;
    if (session != nil) {
        
        if (session.callViewController.callState != CALL_STATE_INCALL &&
            session.outgoing == NO) {
            Options *options = [databaseManage mOptions];
            options.mCallBadge++;
            [databaseManage saveOptions];
            
            [self refreshItemBadge];
            isMissCall = YES;
        }
        if ([UIApplication sharedApplication].applicationState ==
            UIApplicationStateBackground) {
            
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            if (localNotif) {
                
                NSString *stringAlert = [NSString
                                         stringWithFormat:NSLocalizedString(@"Call closed", @"Call closed")];
                if (isMissCall) {
                    stringAlert = [NSString
                                   stringWithFormat:NSLocalizedString(@"Missed call", @"Missed call")];
                }
                localNotif.alertBody = stringAlert;
                
                NSDictionary *userInfo = [NSDictionary
                                          dictionaryWithObjectsAndKeys:kNotifKey_MissCall, kNotifKey, nil];
                localNotif.userInfo = userInfo;
                
                [[UIApplication sharedApplication]
                 presentLocalNotificationNow:localNotif];
            }
        }
    }
    
}

- (void)onInviteClosed:(long)sessionId {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InviteEvent" object:nil];
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    if (session != nil) {
        [self refreshMissCall:session];
        [self endCall:sessionId];
    }
}

- (void)onRemoteUnHold:(long)sessionId
           audioCodecs:(char *)audioCodecs
           videoCodecs:(char *)videoCodecs
           existsAudio:(BOOL)existsAudio
           existsVideo:(BOOL)existsVideo {
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    if (session != nil) {
        [session.callViewController onRemoteUnHold];
    }
}

- (void)onReceivedRefer:(long)sessionId
                referId:(long)referId
                     to:(char *)to
                   from:(char *)from
        referSipMessage:(char *)referSipMessage {
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    if (session != nil) { // Not found the refer session, reject refer.
        [_portSIPHandle rejectRefer:referId];
        return;
    }
    
    //[numpadViewController setStatusText:[NSString  stringWithFormat:@"Received
    // the refer on line %d, refer to %s",index,to]];
    
    // auto accept refer
    long referSessionId = [_portSIPHandle
                           acceptRefer:referId
                           referSignaling:[NSString stringWithUTF8String:referSipMessage]];
    if (referSessionId <= 0) {
        //[numpadViewController setStatusText:[NSString  stringWithFormat:@"Failed
        // to accept the refer."]];
    } else {
        [session.callViewController dismissViewControllerAnimated:NO
                                                       completion:nil];
        [session.callViewController hangupCall:nil];
        NSString *remote = [NSString stringWithUTF8String:to];
        
        HSSession *session = [[HSSession alloc]
                              initWithSessionIdAndUUID:referSessionId
                              callUUID:nil
                              remoteParty:remote
                              displayName:[remote getUriUsername:remote]
                              videoState:YES
                              callOut:YES];
        
        [self.callManager addCall:session];
        
        [tabBarCtr presentViewController:session.callViewController
                                animated:NO
                              completion:nil];
    }
}

- (void)onReferAccepted:(long)sessionId {
}

- (void)onReferRejected:(long)sessionId reason:(char *)reason code:(int)code {
}

- (void)onReceivedRTPPacket:(long)sessionId
                    isAudio:(BOOL)isAudio
                  RTPPacket:(unsigned char *)RTPPacket
                 packetSize:(int)packetSize {
}

- (void)onSendingRTPPacket:(long)sessionId
                   isAudio:(BOOL)isAudio
                 RTPPacket:(unsigned char *)RTPPacket
                packetSize:(int)packetSize {
}

- (void)onTransferTrying:(long)sessionId {
}

- (void)onTransferRinging:(long)sessionId {
    NSString *fileSTR =
    [[NSBundle mainBundle] pathForResource:@"ringtone" ofType:@"wav"];
    int ret2 = [portSIPEngine playAudioFileToRemote:sessionId
                                           filename:fileSTR
                                  fileSamplesPerSec:8000
                                               loop:TRUE];
}

- (void)onACTVTransferSuccess:(long)sessionId {
    int ret2 = [portSIPEngine stopPlayAudioFileToRemote:sessionId];
    [self endCall:sessionId];
    
    [self.numpadViewController refreshReturnButtonState];
};

- (void)onACTVTransferFailure:(long)sessionId
                       reason:(char *)reason
                         code:(int)code {
    int ret2 = [portSIPEngine stopPlayAudioFileToRemote:sessionId];
};

// Signaling Event
- (void)onReceivedSignaling:(long)sessionId message:(char *)message {
}

- (void)onSendingSignaling:(long)sessionId message:(char *)message {
}

#pragma mark
- (void)onWaitingVoiceMessage:(char *)messageAccount
        urgentNewMessageCount:(int)urgentNewMessageCount
        urgentOldMessageCount:(int)urgentOldMessageCount
              newMessageCount:(int)newMessageCount
              oldMessageCount:(int)oldMessageCount {
    
    // NSLog(@"语音邮箱回调 newMessageCount = %d",newMessageCount);
    
    NSString *temocount = [NSString stringWithFormat:@"%d", newMessageCount];
    
    [[NSUserDefaults standardUserDefaults] setObject:temocount
                                              forKey:@"VMcountLabelCount"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"VMcountLabelCount"
     object:nil];
}

- (void)onWaitingFaxMessage:(char *)messageAccount
      urgentNewMessageCount:(int)urgentNewMessageCount
      urgentOldMessageCount:(int)urgentOldMessageCount
            newMessageCount:(int)newMessageCount
            oldMessageCount:(int)oldMessageCount {
}
- (void)onRecvDtmfTone:(long)sessionId tone:(int)tone {
}

- (void)onRecvOptions:(char *)optionsMessage {
}

- (void)onRecvInfo:(char *)infoMessage {
}

// Instant Message/Presence Event
#ifdef HAVE_IM
- (void)onPresenceRecvSubscribe:(long)subscribeId
                fromDisplayName:(char *)fromDisplayName
                           from:(char *)from
                        subject:(char *)subject {
    return;
}

- (void)onPresenceOnline:(char *)fromDisplayName
                    from:(char *)from
               stateText:(char *)stateText {
    [self.contactViewController
     onPresenceOnline:[NSString stringWithUTF8String:fromDisplayName]
     from:[NSString stringWithUTF8String:from]
     stateText:[NSString stringWithUTF8String:stateText]];
}

- (void)onPresenceOffline:(char *)fromDisplayName from:(char *)from {
    [self.contactViewController
     onPresenceOffline:[NSString stringWithUTF8String:fromDisplayName]
     from:[NSString stringWithUTF8String:from]];
}

- (void)onSubscriptionFailure:(long)subscribeId statusCode:(int)statusCode {
    [self.contactViewController onSubscriptionFailure:subscribeId
                                           statusCode:statusCode];
}

- (void)onSubscriptionTerminated:(long)subscribeId {
}

- (void)onRecvNotifyOfSubscription:(long)subscribeId
                     notifyMessage:(char *)notifyMessage
                       messageData:(unsigned char *)messageData
                 messageDataLength:(int)messageDataLength {
}

- (void)onRecvMessage:(long)sessionId
             mimeType:(char *)mimeType
          subMimeType:(char *)subMimeType
          messageData:(unsigned char *)messageData
    messageDataLength:(int)messageDataLength {
}

#pragma mark
- (void)onRecvOutOfDialogMessage:(char *)fromDisplayName
                            from:(char *)from
                   toDisplayName:(char *)toDisplayName
                              to:(char *)to
                        mimeType:(char *)mimeType
                     subMimeType:(char *)subMimeType
                     messageData:(unsigned char *)messageData
               messageDataLength:(int)messageDataLength
                      sipMessage:(char *)sipMessage {
    NSString *strMimetype =
    [[NSString alloc] initWithCString:mimeType
                             encoding:NSASCIIStringEncoding];
    NSString *strsubMimetype =
    [[NSString alloc] initWithCString:subMimeType
                             encoding:NSASCIIStringEncoding];
    
    NSString *strfromDisplayName =
    [[NSString alloc] initWithCString:fromDisplayName
                             encoding:NSASCIIStringEncoding];
    NSString *strfrom =
    [[NSString alloc] initWithCString:from encoding:NSASCIIStringEncoding];
    
    NSString *strtoDisplayName =
    [[NSString alloc] initWithCString:toDisplayName
                             encoding:NSASCIIStringEncoding];
    NSString *strto =
    [[NSString alloc] initWithCString:to encoding:NSASCIIStringEncoding];
    NSData *data =
    [[NSData alloc] initWithBytes:messageData length:messageDataLength];
    NSString *strContent =
    [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *portsipPushId = [_portSIPHandle
                               getSipMessageHeaderValue:[[NSString alloc]
                                                         initWithCString:(const char *)sipMessage
                                                         encoding:NSASCIIStringEncoding]
                               headerName:@"portsip-push-id"];
    NSLog(@"pushxxxx portsip-push-id = %@", portsipPushId);
    if (portsipPushId == NULL || portsipPushId.length == 0) {
        portsipPushId = [_portSIPHandle
                         getSipMessageHeaderValue:[[NSString alloc]
                                                   initWithCString:(const char *)sipMessage
                                                   encoding:NSASCIIStringEncoding]
                         headerName:@"x-push-id"];
        NSLog(@"pushxxxx x-push-id = %@", portsipPushId);
    }
    long messageID;
    if (portsipPushId == NULL || portsipPushId.length == 0) {
        messageID = arc4random();
        messageID= abs(messageID);
    }else{
        messageID = (long)[portsipPushId longLongValue];
    }
    NSTimeInterval recvTime = [[NSDate date] timeIntervalSince1970];
    [self onRecvOutOfDialogMessage:strfromDisplayName
                              from:strfrom
                     toDisplayName:strtoDisplayName
                                to:strto
                          mimeType:strMimetype
                       subMimeType:strsubMimetype
                       messageData:strContent
                         messageID:messageID
                       messageTime:recvTime];
}

- (void)onRecvOutOfDialogMessage:(NSString *)fromDisplayName
                            from:(NSString *)from
                   toDisplayName:(NSString *)toDisplayName
                              to:(NSString *)to
                        mimeType:(NSString *)mimeType
                     subMimeType:(NSString *)subMimeType
                     messageData:(NSString *)messageData
                       messageID:(long)messageID
                     messageTime:(long)time {
    if (!([mimeType isEqualToString:@"text"] &&
          [subMimeType isEqualToString:@"plain"]) &&
        !([MIME_MEDIA_APP hasPrefix:mimeType] &&
          [MIME_MEDIA_APP_JSON hasPrefix:subMimeType])) {
        return;
    }
    
    History *message = [databaseManage selectMessageByMessageId:messageID];
    if (message != nil)
        return;
    
    NSString *fromUserName = [from getUriUsername:from];
    NSString *toUserName = [to getUriUsername:to];
    
    NSString *remoteParty = [self getFullRemoteParty:fromUserName];
    NSString *localParty = [self getFullRemoteParty:toUserName];
    
    NSString *remoteDisplayName = fromDisplayName;
    
    if (remoteDisplayName == nil ||
        [remoteDisplayName
         stringByTrimmingCharactersInSet:[NSCharacterSet
                                          whitespaceAndNewlineCharacterSet]]
        .length == 0) {
        remoteDisplayName = fromUserName;
    }
    
    HSChatSession *session = [databaseManage getChatSession:localParty RemoteUri:remoteParty
                                                DisplayName:remoteDisplayName ContactId:@""];
    
    if(session == nil){
        return;
    }
    ////////
    NSTimeInterval recvTime = time;
    
    NSData *data = [messageData dataUsingEncoding:NSUTF8StringEncoding];
    Contact *contact = [contactView getContactByPhoneNumber:from];
    NSString *nickName = nil;
    if (contact != nil) {
        nickName = contact.displayName;
    } else {
        nickName = remoteDisplayName;
    }
    NSString *totalMimetype =
    [mimeType stringByAppendingPathComponent:subMimeType];
    
    History *history =
    [[History alloc] initWithName:0
                    byRemoteParty:from
                    byDisplayName:nickName
                     byLocalParty:shareAppDelegate.account.userName
               byLocalDisplayname:shareAppDelegate.account.accountName
                      byTimeStart:recvTime
                       byTimeStop:recvTime
                       byMediaype:MediaType_Chat
                     byCallStatus:INCOMING_SUCESS
                        byContent:data];
    history.mRead = FALSE;
    history.mimeType = totalMimetype;
    int historyid = -1;
    NSDictionary *jsonConent = [History parserMessage:messageData];
    NSString *msgType = [jsonConent valueForKey:KEY_MESSAGE_TYPE];
    NSString *loadUrl = [jsonConent valueForKey:KEY_FILE_URL];
    NSString *fileName = [jsonConent valueForKey:KEY_FILE_NAME];
    
    
    
    NSString *messageType = NSLocalizedString(@"Unknow_Message", "message");
    
    if ([MESSAGE_TYPE_AUDIO isEqualToString:msgType]) {
        messageType = NSLocalizedString(@"Audio_Message", "audio message");
        
        if (loadUrl == NULL || loadUrl == nil || loadUrl.length < 1) {
            history.mStatus = INCOMING_ATTACHFAILED;
        } else {
            history.mStatus = INCOMING_PROCESSING;
        }
        
        historyid = [databaseManage insertChatHistoryNew:session.mRowid messageid:messageID
                                             withHistory:history
                                                mimetype:msgType
                                                playLong:0];
        
        if (historyid > 0 && history.mStatus == INCOMING_PROCESSING) {
            NSString *mime = [NSString
                              stringWithFormat:@"%@%@", MIME_MEDIA_AUDIO, MIME_MEDIA_AUDIO_AMR];
            [httpHelper downloadFile:loadUrl
                            filepath:@""
                            mimetype:mime
                           historyid:historyid];
        }
        
    } else if ([MESSAGE_TYPE_VIDEO isEqualToString:msgType]) {
        
        messageType = NSLocalizedString(@"Video_Message", "video message");
        
        if (loadUrl == NULL || loadUrl == nil || loadUrl.length < 1) {
            history.mStatus = INCOMING_ATTACHFAILED;
        } else {
            history.mStatus = INCOMING_PROCESSING;
        }
        historyid = [databaseManage insertChatHistoryNew:session.mRowid messageid:messageID
                                             withHistory:history
                                                mimetype:msgType
                                                playLong:0];
        if (historyid > 0 && history.mStatus == INCOMING_PROCESSING) {
            NSString *mime = [NSString
                              stringWithFormat:@"%@%@", MIME_MEDIA_VIDEO, MIME_MEDIA_VIDEO_MP4];
            [httpHelper downloadFile:loadUrl
                            filepath:@""
                            mimetype:mime
                           historyid:historyid];
        }
        
    } else if ([MESSAGE_TYPE_IMAGE isEqualToString:msgType]) {
        messageType = NSLocalizedString(@"Image_Message", "image message");
        if (loadUrl == NULL || loadUrl == nil || loadUrl.length < 1) {
            history.mStatus = INCOMING_ATTACHFAILED;
        } else {
            history.mStatus = INCOMING_PROCESSING;
        }
        historyid = [databaseManage insertChatHistoryNew:session.mRowid messageid:messageID
                                             withHistory:history
                                                mimetype:msgType
                                                playLong:0];
        if (historyid > 0 && history.mStatus == INCOMING_PROCESSING) {
            NSString *mime = [NSString
                              stringWithFormat:@"%@%@", MIME_MEDIA_IMAGE, MIME_MEDIA_IMAGE_JPG];
            [httpHelper downloadFile:loadUrl
                            filepath:@""
                            mimetype:mime
                           historyid:historyid];
        }
        
    } else if ([MESSAGE_TYPE_FILE isEqualToString:msgType]) {
        
        messageType = NSLocalizedString(@"File_Message", "file message");
        if (loadUrl == NULL || loadUrl == nil || loadUrl.length < 1) {
            history.mStatus = INCOMING_ATTACHFAILED;
        } else {
            history.mStatus = INCOMING_PROCESSING; //有附件需要处理
        }
        historyid = [databaseManage insertChatHistoryNew:session.mRowid messageid:messageID
                                             withHistory:history
                                                mimetype:msgType
                                                playLong:0];
        //    historyid = [databaseManage insertChatHistory:messageID
        //                                      withHistory:history
        //                                         mimetype:totalMimetype
        //                                         playLong:0];
        if (historyid > 0 && history.mStatus == INCOMING_PROCESSING) {
            NSString *mime =
            [NSString stringWithFormat:@"%@%@", CUSTOM_MIME_MEDIA_FILE, fileName];
            [httpHelper downloadFile:loadUrl
                            filepath:@""
                            mimetype:mime
                           historyid:historyid];
        }
    } else { // text 或其他不处理的mime 直接设置为成功
        //    historyid = [databaseManage insertChatHistory:messageID
        //                                      withHistory:history
        //                                         mimetype:totalMimetype
        //                                         playLong:0];
        historyid = [databaseManage insertChatHistoryNew:session.mRowid messageid:messageID
                                             withHistory:history
                                                mimetype:msgType
                                                playLong:0];
    }
    
    /////////
    
    if ([UIApplication sharedApplication].applicationState ==
        UIApplicationStateBackground) {
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        
        NSString *nickName = nil;
        Contact *contact = [contactView getContactByPhoneNumber:from];
        if (contact != nil) {
            nickName = contact.displayName;
        } else {
            nickName = remoteDisplayName;
        }
        
        NSString *alterMessage = [NSLocalizedString(
                                                    @"Message_Tips", @"You have received a message from disname.")
                                  stringByReplacingOccurrencesOfString:@"disname"
                                  withString:nickName];
        
        localNotif.alertBody =
        [alterMessage stringByReplacingOccurrencesOfString:@"message"
                                                withString:messageType];
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        
        Options *options = [databaseManage mOptions];
        int unreadMsgCount = [databaseManage getAllUnreadMessageCount:shareAppDelegate.account.LocalUri];
        
        localNotif.applicationIconBadgeNumber =
        options.mCallBadge + options.mMsgBadge+unreadMsgCount;
        
        localNotif.repeatInterval = 0;
        NSDictionary *userInfo = [NSDictionary
                                  dictionaryWithObjectsAndKeys:kNotifKey_IncomingMsg, kNotifKey, nil];
        localNotif.userInfo = userInfo;
        
        NSString *portsipPushId = [NSString stringWithFormat:@"%d", messageID];
        NSArray *portsipPushIdArr = [portsipPushModel jr_getAll];
        
        BOOL find = NO;
        
        for (portsipPushModel *model in portsipPushIdArr) {
            
            NSLog(@"model.portsipPushId======%@", model.portsipPushId);
            
            if ([portsipPushId isEqualToString:model.portsipPushId]) {
                
                find = YES;
                
                break;
            }
        }
        
        if (!find) {
            
            [[UIApplication sharedApplication]
             presentLocalNotificationNow:localNotif];
            
            portsipPushModel *model = [[portsipPushModel alloc] init];
            
            model.portsipPushId = portsipPushId;
            
            [model jr_saveOrUpdate];
            
            NSLog(@"chat message onRecvOutOfDialogMessage Id= %ld", messageID);
            [self.messagesViewController onRecvOutOfDialogMessage:messageID
                                                  fromDisplayName:remoteDisplayName
                                                             from:remoteParty
                                                         mimeType:mimeType
                                                      subMimeType:subMimeType
                                                      messageData:messageData
                                                      messageTime:time];
        }
        
    } else {
        
        NSLog(@"chat message onRecvOutOfDialogMessage Id= %ld", messageID);
        [self.messagesViewController onRecvOutOfDialogMessage:messageID
                                              fromDisplayName:remoteDisplayName
                                                         from:remoteParty
                                                     mimeType:mimeType
                                                  subMimeType:subMimeType
                                                  messageData:messageData
                                                  messageTime:time];
        [self refreshItemBadge];
        
    }
}

- (void)onSendMessageSuccess:(long)sessionId messageId:(long)messageId {
}

- (void)onSendMessageFailure:(long)sessionId
                   messageId:(long)messageId
                      reason:(char *)reason
                        code:(int)code {
}

- (void)onSendOutOfDialogMessageSuccess:(long)messageId
                        fromDisplayName:(char *)fromDisplayName
                                   from:(char *)from
                          toDisplayName:(char *)toDisplayName
                                     to:(char *)to {
    NSLog(@"chat message onSendOutOfDialogMessageSuccess Id= %d", messageId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messagesViewController onSendOutOfDialogMessageSuccess:messageId
                                                     fromDisplayName:fromDisplayName
                                                                from:from
                                                       toDisplayName:toDisplayName
                                                                  to:to];
    });
}

- (void)onSendOutOfDialogMessageFailure:(long)messageId
                        fromDisplayName:(char *)fromDisplayName
                                   from:(char *)from
                          toDisplayName:(char *)toDisplayName
                                     to:(char *)to
                                 reason:(char *)reason
                                   code:(int)code {
    NSLog(@"chat message onSendOutOfDialogMessageSuccess Id= %d", messageId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messagesViewController onSendOutOfDialogMessageFailure:messageId
                                                     fromDisplayName:fromDisplayName
                                                                from:from
                                                       toDisplayName:toDisplayName
                                                                  to:to
                                                              reason:reason
                                                                code:code];
    });
}
#endif // HAVE_IM
- (void)onPresenceRecvNotify:(char *)subscriptionState
                 contentType:(char *)contentType
                 contentBody:(unsigned char *)content
               contentLength:(int)contentLength {
}

- (int)onVideoRawCallback:(long)sessionId
        videoCallbackMode:(int)videoCallbackMode
                    width:(int)width
                   height:(int)height
                     data:(unsigned char *)data
               dataLength:(int)dataLength {
    return 0;
}

- (void)onAudioRawCallback:(long)sessionId
         audioCallbackMode:(int)audioCallbackMode
                      data:(unsigned char *)data
                dataLength:(int)dataLength
            samplingFreqHz:(int)samplingFreqHz {
}

- (void)onPlayAudioFileFinished:(long)sessionId fileName:(char *)fileName {
    
    NSLog(@"onPlayAudioFileFinished onPlayAudioFileFinished "
          @"onPlayAudioFileFinished");
}

- (void)onPlayVideoFileFinished:(long)sessionId {
    
    NSLog(@"onPlayAudioFileFinished  ");
}

- (void)onDialogStateUpdated:(char *)BLFMonitoredUri
              BLFDialogState:(char *)BLFDialogState
                 BLFDialogId:(char *)BLFDialogId
          BLFDialogDirection:(char *)BLFDialogDirection {
}

#pragma mark - VoIP PUSH
- (void)addPushSupportWithPortPBX:(BOOL)enablePush {
    
    //  if (_VoIPPushToken == nil || _APNsPushToken == nil) {
    //    return;
    //  }
    
    // This VoIP Push is only work with
    // PortPBX(https://www.portsip.com/portsip-pbx/)
    // if you want work with other PBX, please contact your PBX Provider
    [_portSIPHandle clearAddedSipMessageHeaders];
    
    NSString *pushMessage;
    NSString *enableStatus = @"false";
    NSString *appID = [[NSBundle mainBundle] bundleIdentifier];
    if (enablePush) {
        enableStatus = @"true";
    }
    
    NSString *token = databaseManage.mOptions.supportCallKit?[[NSString alloc]
                                                              initWithFormat:@"%@|%@", _VoIPPushToken, _APNsPushToken]:[[NSString alloc]
                                                                                                                        initWithFormat:@"|%@", _APNsPushToken];
    
    pushMessage =
    [NSString stringWithFormat:@"device-os=ios;device-uid=%@;allow-call-push="
     @"%@;allow-message-push=%@;app-id=%@",
     token, enableStatus, enableStatus, appID];
    
    [_portSIPHandle addSipMessageHeader:-1
                             methodName:@"REGISTER"
                                msgType:1
                             headerName:@"x-p-push"
                            headerValue:pushMessage];
}

#pragma mark -
#pragma mark processPushMessageFromPortPBX

- (void)processPushMessageFromPortPBX:(NSDictionary *)dictionaryPayload
                withCompletionHandler:(void (^)(void))completion {
    
    NSDictionary *parsedObject = dictionaryPayload;
    
    BOOL isCall = YES;
    BOOL isVideoCall = NO;
    NSString *strMessage =nil;
    NSString *msgType = [parsedObject valueForKey:@"msg_type"];
    // if(msgType.count > 0 && [msgType[0]  isEqual: @"call"])
    if (msgType.length > 0) {
        if ([msgType isEqual:@"audio"]) {
            isVideoCall = NO;
        }else if ([msgType isEqual:@"video"]) {
            isVideoCall = YES;
        }else if ([msgType isEqual:@"im"]) {
            isCall = FALSE;
            
            NSDictionary *apsContent =[parsedObject valueForKey:@"aps"];
            if(apsContent){
                NSDictionary *alterContent = [apsContent valueForKey:@"alert"];
                if(alterContent){
                    strMessage = [alterContent valueForKey:@"body"];
                }
            }
        }
    }else{
        return;
    }
    
    NSUUID *uuid = nil;
    NSString *pushId = [parsedObject valueForKey:@"x-push-id"];
    if (pushId != nil) {
        uuid = [[NSUUID alloc] initWithUUIDString:pushId];
        
        NSLog(@"processPushMessageFromPortPBX uuid: %@", uuid);
    }
    if (uuid == nil) {
        uuid = [NSUUID new];
    }
    
    NSString *sendFrom = [parsedObject valueForKey:@"send_from"];
    NSString *sendTo = [parsedObject valueForKey:@"send_to"];
    NSString *remoteParty = [self getShortRemoteParty:sendFrom andCallee:sendTo];
    NSString *remoteDisplayName = [remoteParty getUriUsername:remoteParty];
    if(isCall){
        if (!databaseManage.mOptions.enableCallKit) {
            // If not enable Call Kit, show the local Notification
            UILocalNotification *backgroudMsg = [[UILocalNotification alloc] init];
            
            NSString *alertBody = [NSString
                                   stringWithFormat:@"%@:%@ To:%@",
                                   NSLocalizedString(@"You receive a new call From",
                                                     @"You receive a new call From"),
                                   remoteParty, sendTo];
            
            backgroudMsg.alertBody = alertBody;
            backgroudMsg.soundName = @"ringtone.mp3";
            backgroudMsg.applicationIconBadgeNumber =
            [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            [[UIApplication sharedApplication]
             presentLocalNotificationNow:backgroudMsg];
        } else {
            long sessionid = arc4random()%10000;
            
            [self.callManager incomingCall:-sessionid
                               existsVideo:isVideoCall
                               remoteParty:remoteParty
                         remoteDisplayName:remoteDisplayName
                                  callUUID:uuid
                     withCompletionHandler:completion];
            
            [_portSIPHandle refreshRegister];
            [self beginBackgroundTaskForRegister];
        }
    }else{
        if(strMessage){
            //[ID，time，mime]
            //[self onRecvOfflineDialogMessage:<#(long)#> fromDisplayName:remoteDisplayName from:remoteParty toDisplayName:sendTo to:sendTo mimeType:<#(NSString *)#> subMimeType:<#(NSString *)#> messageData:strMessage messageTime:<#(long)#>]
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"_APNsPushToken didReceiveRemoteNotification:%@", userInfo);
    [self processPushMessageFromPortPBX:userInfo  withCompletionHandler:{}];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"remoteNotifi didReceiveRemoteNotificationfetch:%@", userInfo);
    [self processPushMessageFromPortPBX:userInfo  withCompletionHandler:{}];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    _APNsPushToken = [self stringFromDeviceToken:deviceToken];
    NSLog(@"_APNsPushToken :%@", deviceToken);
    [self refreshPushStatusToSipServer:YES];
}

- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:nil];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

- (NSString *)stringFromDeviceToken:(NSData *)deviceToken {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0) {
        NSUInteger length = deviceToken.length;
        if (length == 0) {
            return nil;
        }
        
        Byte *buffer = new Byte[length];
        [deviceToken getBytes:buffer range:NSMakeRange(0, length)];
        NSMutableString *hexString =
        [NSMutableString stringWithCapacity:(length * 2)];
        for (int i = 0; i < length; ++i) {
            [hexString appendFormat:@"%02x", buffer[i]];
        }
        return [hexString copy];
    } else {
        NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
        
        token =
        [token stringByTrimmingCharactersInSet:
         [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        
        return [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
}

// iOS version > 10.0 Background
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response
         withCompletionHandler:(nonnull void (^)(void))completionHandler {
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSLog(@"Background Notification:%@", userInfo  );
    [self processPushMessageFromPortPBX:userInfo  withCompletionHandler:{}];
    completionHandler();
}

// iOS version > 10.0 foreground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:
(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"Foreground Notification:%@", userInfo);
    
    [self processPushMessageFromPortPBX:userInfo  withCompletionHandler:{}];
    completionHandler(UNNotificationPresentationOptionBadge);
}

- (void)pushRegistry:(PKPushRegistry *)registry
didUpdatePushCredentials:(PKPushCredentials *)credentials
             forType:(PKPushType)type {
    _VoIPPushToken = [self stringFromDeviceToken:credentials.token];
    
    NSLog(@"_VoIPPushToken=======%@", _VoIPPushToken);
    [self refreshPushStatusToSipServer:YES];
}

- (void)refreshPushStatusToSipServer:(BOOL)addPushHeader {
    if (addPushHeader) {
        [self addPushSupportWithPortPBX:YES];
    } else {
        // remove push header
        [_portSIPHandle clearAddedSipMessageHeaders];
    }
    
    [_portSIPHandle refreshRegister];
}

// iOS version > 11.0
- (void)pushRegistry:(PKPushRegistry *)registry
didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
             forType:(PKPushType)type
withCompletionHandler:(void (^)(void))completion {
    
    if (([UIApplication sharedApplication].applicationState ==
         UIApplicationStateActive ||
         [self.callManager getConnectCallNum] > 0)) {
        NSLog(@"didReceiveIncomingPushWith:ignore push message when "
              @"ApplicationStateActive or have active call. Payload: %@",
              payload.dictionaryPayload);
        return;
    }
    
    NSLog(@" pushRegistry Payload: %@", payload.dictionaryPayload);
    [self processPushMessageFromPortPBX:payload.dictionaryPayload
                  withCompletionHandler:completion];
}

// 8.0 < iOS version < 11.0
- (void)pushRegistry:(PKPushRegistry *)registry
didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
             forType:(PKPushType)type {
    if (([UIApplication sharedApplication].applicationState ==
         UIApplicationStateActive ||
         [self.callManager getConnectCallNum] > 0)) {
        NSLog(@"didReceiveIncomingPushWith:ignore push message when "
              @"ApplicationStateActive or have active call. Payload: %@",
              payload.dictionaryPayload);
        return;
    }
    
    NSLog(@" pushRegistry Payload: %@", payload.dictionaryPayload);
    
    [self processPushMessageFromPortPBX:payload.dictionaryPayload
                  withCompletionHandler:nil];
};

#pragma mark - UIApplicationDelegate FinishLaunch
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if(launchOptions){
        //        NSURL *launchUrl = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        //        UILocalNotification *localNotifi = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        NSDictionary *remoteNotifi = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if(remoteNotifi){
            NSLog(@"remoteNotifi didFinishLaunchingWithOptions:%@", remoteNotifi);
        }
    }
    
    [self redirectNSLogToDocumentFolder];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    //_mKeepAwake = [[HSKeepAwake alloc] init];
    //_mMissCall = [[NSMutableArray alloc] init];
    
    internetReach = [Reachability reachabilityForInternetConnection];
    _netStatus = [internetReach currentReachabilityStatus];
    _IsPortPBX = NO;
    
    [self startNotifierNetwork];
    
    [PortSipSignalHandler instance]; //异常提示
    
    // init Engine
    _portSIPHandle = [[PortSIPHandle alloc] init];
    _portSIPHandle.delegate = self;
    
    _cxProvide = [PortCxProvider sharedInstance];
    self.callManager = [[CallManager alloc] initWithSDK:_portSIPHandle];
    self.callManager.delegate = self;
    _cxProvide.callManager = self.callManager;
    
    _audioOutRouteType = -1; // default is speaker
    httpHelper.offlineMsgDelegate = self;
    databaseManage.opratorDel =self;
    [databaseManage loadNetworkOptions];
    [databaseManage loadAVOptions];
    
    // todo sholud call again, when database data is changed.
    //[self.callManager
    // setPlayDTMFMethod:(DTMF_METHOD)(databaseManage.mOptions.dtmfOfInfo)
    // playDTMFTone:databaseManage.mOptions.playDtmfTone];
    
    // request User notification
    if ([UIApplication
         instancesRespondToSelector:@selector(
                                              registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication]
         registerUserNotificationSettings:
         [UIUserNotificationSettings
          settingsForTypes:UIUserNotificationTypeAlert |
          UIUserNotificationTypeBadge |
          UIUserNotificationTypeSound
          categories:nil]];
    }
    
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] ==
        CNAuthorizationStatusNotDetermined) {
        [contactStore
         requestAccessForEntityType:CNEntityTypeContacts
         completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView =
                    [[UIAlertView alloc] initWithTitle:@"Deny Access"
                                               message:@"Deny"
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"cancel", nil];
                    [alertView show];
                });
                
            }
        }];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    
    [self readyOtherSql];
    
    [self readyscore];
    
    BOOL productID999 =
    [[NSUserDefaults standardUserDefaults] boolForKey:@"productID999"];
    
    if (!productID999) {
        
        //    [self buy];
    }
#ifndef DEBUG
    //[Bugly startWithAppId:@"cec44c5508"];
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self.window makeKeyAndVisible];
    
    UIStoryboard *mainStoryBoard =
    [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    HSLoginViewController *loginCtrl = [mainStoryBoard
                                        instantiateViewControllerWithIdentifier:@"HSLoginViewController"];
    
    self.window.rootViewController = loginCtrl;
    
    // Register APNs PUSH
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        // iOS > 10
        UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge |
                                                 UNAuthorizationOptionSound |
                                                 UNAuthorizationOptionAlert)
                              completionHandler:^(BOOL granted,
                                                  NSError *_Nullable error) {
            
            if (!error) {
                NSLog(@"request User Notification succeeded!");
            }
        }];
    } else { // iOS 8-10
        if ([UIApplication instancesRespondToSelector:
             @selector(registerUserNotificationSettings:)]) {
            [[UIApplication sharedApplication]
             registerUserNotificationSettings:
             [UIUserNotificationSettings
              settingsForTypes:UIUserNotificationTypeAlert |
              UIUserNotificationTypeBadge |
              UIUserNotificationTypeSound
              categories:nil]];
        }
    }

    [application registerForRemoteNotifications];
    
    return YES;
}

- (void)readyOtherSql {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(
                                                                   NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *filePath =
    [documentsPath stringByAppendingPathComponent:@"callListModel.sqlite"];
    
    [[JRDBMgr shareInstance] setDefaultDatabasePath:filePath];
    [[JRDBMgr shareInstance] registerClazzes:@[
        [callListModel class],
        
        [addFriendModel class],
        
        [portsipPushModel class],
        
    ]];
    [JRDBMgr shareInstance].debugMode = YES;
}

#pragma mark

- (void)buy {
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    NSLog(@"buy buy buy buy ");
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:
(SKPaymentQueue *)queue {
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productID = transaction.payment.productIdentifier;
        
        [purchasedItemIDs addObject:productID];
    }
    
    NSLog(@"purchasedItemIDs==%@", purchasedItemIDs);
    
    BOOL productID999 = NO;
    
    for (NSString *productID in purchasedItemIDs) {
        
        if ([productID isEqualToString:@"20171205999"]) {
            
            NSLog(@"已经内购过");
            
            productID999 = YES;
            
            [[NSUserDefaults standardUserDefaults] setBool:productID999
                                                    forKey:@"productID999"];
        }
    }
}

- (void)paymentQueue:(nonnull SKPaymentQueue *)queue
 updatedTransactions:
(nonnull NSArray<SKPaymentTransaction *> *)transactions {
}

#pragma mark -
#pragma mark
- (void)readyscore {
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(readyscoreAlertViewNot)
     name:@"readyscoreAlertViewNot"
     object:nil];
    
    NSInteger readyscoreAlertViewNot = [[NSUserDefaults standardUserDefaults]
                                        integerForKey:@"readyscoreAlertViewNot"];
    
    //    NSLog(@"readyscoreAlertViewNotidnex====%d",readyscoreAlertViewNotidnex);
    
    if (readyscoreAlertViewNot == 0) {
        
        [[NSUserDefaults standardUserDefaults]
         setInteger:readyscoreAlertViewNot
         forKey:@"readyscoreAlertViewNot"];
    }
}

- (void)readyscoreAlertViewNot {
    
    UIAlertView *score = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Tips", @"Tips")
                          message:NSLocalizedString(@"Appreciated with 5-star comment",
                                                    @"Appreciated with 5-star comment")
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Comment later", @"Comment later")
                          otherButtonTitles:NSLocalizedString(@"Comment us", @"Comment us"), nil];
    
    score.tag = 808;
    
    [score show];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 808) {
        
        if (buttonIndex == 0) {
            
            NSLog(@"quxiao");
            
        } else if (buttonIndex == 1) {
            
            //              NSLog(@"ok");
            //
            //               [[UIApplication sharedApplication]openURL:[NSURL
            //               URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=426903818&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
            
            if ([SKStoreReviewController
                 respondsToSelector:@selector(requestReview)]) {
                [SKStoreReviewController requestReview];
            } else {
                NSString *nsStringToOpen = [NSString
                                            stringWithFormat:
                                            @"itms-apps://itunes.apple.com/app/id%@?action=write-review",
                                            @"426903818"]; //替换为对应的APPID
                [[UIApplication sharedApplication]
                 openURL:[NSURL URLWithString:nsStringToOpen]];
            }
        }
    }
}


- (void)initTabbar {
    
    if(self.numpadViewController==nil){
        NSLog(@"initTabbar initTabbar");
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        MLTabBarController *tabbar = [mainStoryboard instantiateViewControllerWithIdentifier:@"Tabbar"];;
        
        //_mSessionMArray = [NSMutableArray array];
        _mConferenceState = NO;
        //    [[tabbar tabBar] appearance] setBarTintColor:[UIColor redColor]];
        [tabbar.tabBar setBackgroundColor:UIColor.blackColor];
        [tabbar.tabBar setBarTintColor:UIColor.blackColor];
        //***************       Numpad BarItem      *********************
        UIImage *numpadImage = [UIImage imageNamed:@"toolbar_ico_dial_default"];
        numpadImage =
        [numpadImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIImage *numpadSelectedImage =
        [UIImage imageNamed:@"toolbar_ico_dial_pressed"];
        UITabBarItem *numpadBarItem;
        numpadBarItem = [[UITabBarItem alloc]
                         initWithTitle:NSLocalizedString(@"Numpad", @"Numpad")
                         image:numpadImage
                         selectedImage:numpadSelectedImage];
        
        [numpadBarItem
         setImage:[numpadImage
                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [numpadBarItem setSelectedImage:[numpadSelectedImage
                                         imageWithRenderingMode:
                                         UIImageRenderingModeAlwaysOriginal]];
        
        [numpadBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#929292"]
        }
                                     forState:UIControlStateNormal];
        [numpadBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : MAIN_COLOR
        }
                                     forState:UIControlStateSelected];
        
        self.numpadViewController =
        [[tabbar viewControllers] objectAtIndex:kTabBarIndex_Numpad];
        self.numpadViewController.tabBarItem = numpadBarItem;
        
        //***************       Recent BarItem      *********************
        UIImage *recentImage = [UIImage imageNamed:@"toolbar_ico_history_default"];
        
        recentImage =
        [recentImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIImage *recentSelectedImage =
        [UIImage imageNamed:@"toolbar_ico_history_pressed"];
        UITabBarItem *recentBarItem = [[UITabBarItem alloc]
                                       initWithTitle:NSLocalizedString(@"Recents", @"Recents")
                                       image:recentImage
                                       selectedImage:recentSelectedImage];
        
        [recentBarItem
         setImage:[recentImage
                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [recentBarItem setSelectedImage:[recentSelectedImage
                                         imageWithRenderingMode:
                                         UIImageRenderingModeAlwaysOriginal]];
        
        [recentBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#929292"]
        }
                                     forState:UIControlStateNormal];
        [recentBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : MAIN_COLOR
        }
                                     forState:UIControlStateSelected];
        
        // Navigation Controller -> ViewController
        UINavigationController *recentsNavigationController =
        [[tabbar viewControllers] objectAtIndex:kTabBarIndex_Recents];
        self.recentsViewController =
        [[recentsNavigationController viewControllers] objectAtIndex:0];
        recentsNavigationController.tabBarItem = recentBarItem;
        
        //***************       Contact BarItem      *********************
        UIImage *contactImage = [UIImage imageNamed:@"toolbar_ico_contact_default"];
        contactImage =
        [contactImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIImage *contactSelectedImage =
        [UIImage imageNamed:@"toolbar_ico_contact_pressed"];
        
        UITabBarItem *contactBarItem = [[UITabBarItem alloc]
                                        initWithTitle:NSLocalizedString(@"Contacts", @"Contacts")
                                        image:contactImage
                                        selectedImage:contactSelectedImage];
        
        [contactBarItem
         setImage:[contactImage
                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [contactBarItem setSelectedImage:[contactSelectedImage
                                          imageWithRenderingMode:
                                          UIImageRenderingModeAlwaysOriginal]];
        
        [contactBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#929292"]
        }
                                      forState:UIControlStateNormal];
        [contactBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : MAIN_COLOR
        }
                                      forState:UIControlStateSelected];
        
        // Navigation Controller-> ViewController
        UINavigationController *contactNavigationController =
        [[tabbar viewControllers] objectAtIndex:kTabBarIndex_Contacts];
        self.contactViewController =
        [[contactNavigationController viewControllers] objectAtIndex:0];
        contactNavigationController.tabBarItem = contactBarItem;
        
        //***************       Message BarItem      *********************
        UIImage *messagesImage = [UIImage imageNamed:@"toolbar_ico_message_default"];
        messagesImage =
        [messagesImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIImage *messagesSelectedImage =
        [UIImage imageNamed:@"toolbar_ico_message_pressed"];
        UITabBarItem *messagesBarItem = [[UITabBarItem alloc]
                                         initWithTitle:NSLocalizedString(@"Messages", @"Messages")
                                         image:messagesImage
                                         selectedImage:messagesSelectedImage];
        
        [messagesBarItem
         setImage:[messagesImage
                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [messagesBarItem
         setSelectedImage:
         [messagesSelectedImage
          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        [messagesBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#929292"]
        }
                                       forState:UIControlStateNormal];
        [messagesBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : MAIN_COLOR
        }
                                       forState:UIControlStateSelected];
        
        // Navigation Controller -> ViewController
        UINavigationController *messagesNavigationController =
        [[tabbar viewControllers] objectAtIndex:kTabBarIndex_Messages];
        self.messagesViewController =
        [[messagesNavigationController viewControllers] objectAtIndex:0];
        messagesNavigationController.tabBarItem = messagesBarItem;
        
        //***************       Settings BarItem      *********************
        UIImage *settingsImage = [UIImage imageNamed:@"toolbar_ico_set_default"];
        settingsImage =
        [settingsImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIImage *settingsSelectedImage =
        [UIImage imageNamed:@"toolbar_ico_set_pressed"];
        UITabBarItem *settingsBarItem = [[UITabBarItem alloc]
                                         initWithTitle:NSLocalizedString(@"Settings", @"Settings")
                                         image:settingsImage
                                         selectedImage:settingsSelectedImage];
        
        [settingsBarItem
         setImage:[settingsImage
                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [settingsBarItem
         setSelectedImage:
         [settingsSelectedImage
          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        [settingsBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#929292"]
        }
                                       forState:UIControlStateNormal];
        [settingsBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : MAIN_COLOR
        }
                                       forState:UIControlStateSelected];
        
        // Navigation Controller -> ViewController
        UINavigationController *settingNavigationController =
        [[tabbar viewControllers] objectAtIndex:kTabBarIndex_Settings];
        self.settingsViewController =
        [[settingNavigationController viewControllers] objectAtIndex:0];
        settingNavigationController.tabBarItem = settingsBarItem;
        
        //***************       webview BarItem      *********************
        //*
        UIImage *webviewImage = [UIImage imageNamed:@"tabbar_webpage_dimblue.png"];
        webviewImage =
        [webviewImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIImage *webviewSelectedImage = [UIImage imageNamed:@"tabbar_webpage.png"];
        UITabBarItem *webviewBarItem =
        [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home", @"Home")
                                      image:webviewImage
                              selectedImage:webviewSelectedImage];
        
        [webviewBarItem
         setImage:[webviewImage
                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [webviewBarItem setSelectedImage:[webviewSelectedImage
                                          imageWithRenderingMode:
                                          UIImageRenderingModeAlwaysOriginal]];
        
        [webviewBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : [UIColor colorWithRed:168.0 / 255
                                                             green:240.0 / 255
                                                              blue:255.0 / 255
                                                             alpha:1]
        }
                                      forState:UIControlStateNormal];
        [webviewBarItem setTitleTextAttributes:@{
            NSForegroundColorAttributeName : [UIColor whiteColor]
        }
                                      forState:UIControlStateSelected];
        
        _webpageViewController =
        [[tabbar viewControllers] objectAtIndex:kTabBarIndex_WebPage];
        _webpageViewController.tabBarItem = webviewBarItem; //*/
        
        //***************       Tabbar setting      *********************
        
        self.window.rootViewController = tabbar;
        tabbar.delegate = self;
        
        [tabbar setSelectedIndex:kTabBarIndex_Numpad];
        _mTabBarSelectedItem = kTabBarIndex_Numpad;
        
#if !defined(HAVE_WEBPAGE) || !defined(HAVE_IM)
        // remove unuse tab
        NSMutableArray *viewControllers =
        [NSMutableArray arrayWithArray:tabbar.viewControllers];
        
#ifndef HAVE_WEBPAGE
        [viewControllers removeObjectAtIndex:kTabBarIndex_WebPage];
#endif
#ifndef HAVE_IM
        [viewControllers removeObjectAtIndex:kTabBarIndex_Messages];
#endif
        
        [tabbar setViewControllers:viewControllers];
#endif
        
        [self refreshItemBadge];
        
        // start network Notifier
        
        [self startNotifierNetwork];
    }
}
- (void)beginBackgroundTaskForRegister {
    _backtaskIdentifier = [[UIApplication sharedApplication]
                           beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTaskForRegister];
    }];
    int interval = 5; // waiting 5 sec, stop endBackgroundTaskForRegister
    [NSTimer
     scheduledTimerWithTimeInterval:interval
     target:self
     selector:@selector(endBackgroundTaskForRegister)
     userInfo:nil
     repeats:NO];
}

- (void)endBackgroundTaskForRegister {
    if (_backtaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_backtaskIdentifier];
        _backtaskIdentifier = UIBackgroundTaskInvalid;
    }
}

- (void)tesettimer {
    
    // NSLog(@"testindex========%d",_testindex++);
}

- (void)doEnterBackground {
    
    if (self.callManager.getConnectCallNum > 0|| !_portSIPHandle.SIPInitialized) {
        return;
    }
    
    if (databaseManage.mOptions.forceBackground && !_IsPortPBX) {
        // Not PortPBX and enable force background,
        
        NSLog(@"startKeepAwake startKeepAwake startKeepAwake");
        
        //        if(_mKeepAwake == nil)
        //        {
        //            _mKeepAwake = [[HSKeepAwake alloc] init];
        //        }
        //        [_mKeepAwake stopKeepAwake];
        //        [_mKeepAwake startKeepAwake];
        [portSIPEngine stopKeepAwake];
        [portSIPEngine startKeepAwake];
        
    } else {
        [_portSIPHandle unRegister];
        [self beginBackgroundTaskForRegister];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self doEnterBackground];
    //    if ([self.window.rootViewController isKindOfClass:[MLTabBarController
    //    class]] &&
    //    ((MLTabBarController*)self.window.rootViewController).selectedIndex ==
    //    kTabBarIndex_Recents) {
    //        [self.recentsViewController cleanBadges];
    //    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    int callNum = self.callManager.getConnectCallNum;
    if (callNum > 0) {
        if (!databaseManage.mOptions.enableCallKit) {
            HSSession *session = self.callManager.getProccessingCall;
            if (session != NULL && !session.callViewController.isViewLoaded) {
                [tabBarCtr presentViewController:session.callViewController
                                        animated:NO
                                      completion:nil];
                if (session.notification != NULL) {
                    [[UIApplication sharedApplication]
                     cancelLocalNotification:session.notification];
                    session.notification = NULL;
                }
            }
        }
        return;
    }
    if(_portSIPHandle.SIPInitialized){
        if (databaseManage.mOptions.forceBackground && !_IsPortPBX) {
            // Not PortPBX and enable force background,
            //[_portSIPHandle stopKeepAwake];
            if (_mKeepAwake != nil) {
                [_mKeepAwake stopKeepAwake];
            }
        } else {
            
            NSLog(@"_portSIPHandle refreshRegister");
            [_portSIPHandle refreshRegister];
        }
    }
    [self refreshItemBadge];
}

- (void)refreshItemBadge {
    Options *options = [databaseManage mOptions];
    
    if (options.mCallBadge) {
        self.recentsViewController.parentViewController.tabBarItem.badgeValue =
        [NSString stringWithFormat:@"%d", options.mCallBadge];
    } else {
        self.recentsViewController.parentViewController.tabBarItem.badgeValue = nil;
    }
    
    int msgCount = options.mMsgBadge+[databaseManage getAllUnreadMessageCount:shareAppDelegate.account.LocalUri];
    if (msgCount>0) {
        self.messagesViewController.parentViewController.tabBarItem.badgeValue =
        [NSString stringWithFormat:@"%d", msgCount];
    } else {
        self.messagesViewController.parentViewController.tabBarItem.badgeValue = nil;
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber =
    options.mCallBadge + msgCount;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if(_portSIPHandle.SIPInitialized){
        NSMutableArray *sipfs = [contactView getSipContacts];
        for (Contact *sip in sipfs) {
            if (sip) {
                [portSIPEngine setPresenceStatus:sip.subscribeID statusText:@"offline"];
            }
        }
        
        [_portSIPHandle unRegisterServer];
        [NSThread sleepForTimeInterval:3.0];
        
        [_portSIPHandle stopKeepAwake];
        [_portSIPHandle unInitialize];
    }
    [databaseManage closeDatabase];
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    
    UITabBarController *tabBarController =
    (UITabBarController *)self.window.rootViewController;
    Options *options = [databaseManage mOptions];
    NSString *notifKey = [notification.userInfo objectForKey:kNotifKey];
    if ([notifKey isEqualToString:kNotifKey_IncomingCall]) {
        tabBarController.selectedIndex = kTabBarIndex_Numpad;
        _mTabBarSelectedItem = kTabBarIndex_Numpad;
        options.mCallBadge = 0;
        application.applicationIconBadgeNumber =
        options.mCallBadge + options.mMsgBadge;
        
        //[self precessIncomingCallNotificationWithNotif:notification];
        NSNumber *sessionId =
        [notification.userInfo objectForKey:kNotifIncomingCall_SessionId];
        NSNumber *existsVideo =
        [notification.userInfo objectForKey:kNotifIncomingCall_ExistsVideo];
        NSString *remoteParty =
        [notification.userInfo objectForKey:kNotifIncomingCall_RemoteParty];
        NSString *remoteDisplayName = [notification.userInfo
                                       objectForKey:kNotifIncomingCall_RemoteDispalyName];
        
        [self onIncomingCallWithoutCallKit:[sessionId longValue]
                               existsVideo:[existsVideo boolValue]
                               remoteParty:remoteParty
                         remoteDisplayName:remoteDisplayName];
        //[self processIncomingCall:[sessionId longValue] existsVideo:[existsVideo
        // boolValue] remoteParty:remoteParty remoteDisplayName:remoteDisplayName];
    } else if ([notifKey isEqualToString:kNotifKey_MissCall]) {
        tabBarController.selectedIndex = kTabBarIndex_Recents;
        _mTabBarSelectedItem = kTabBarIndex_Recents;
    } else if ([notifKey isEqualToString:kNotifKey_IncomingMsg]) {
        
        tabBarController.selectedIndex = kTabBarIndex_Messages;
        _mTabBarSelectedItem = kTabBarIndex_Messages;
    }
    [databaseManage saveOptions];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:
(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return YES;
}

// Called on the main thread after the NSUserActivity object is available. Use
// the data you stored in the NSUserActivity object to re-create what the user
// was doing.
// You can create/fetch any restorable objects associated with the user
// activity, and pass them to the restorationHandler. They will then have the
// UIResponder restoreUserActivityState: method
// invoked with the user activity. Invoking the restorationHandler is optional.
// It may be copied and invoked later, and it will bounce to the main thread to
// complete its work and call
// restoreUserActivityState on all objects.
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler
{
    if (![userActivity.activityType isEqualToString:@"INStartVideoCallIntent"] &&
        ![userActivity.activityType isEqualToString:@"INStartAudioCallIntent"]) {
        return NO;
    }
    
    BOOL isVideo = NO;
    if ([userActivity.activityType isEqualToString:@"INStartVideoCallIntent"]) {
        isVideo = YES;
    }
    
    INInteraction *interaction = userActivity.interaction;
    INStartAudioCallIntent *startAudioCallIntent =
    (INStartAudioCallIntent *)interaction.intent;

    INPerson *contact = startAudioCallIntent.contacts[0];

    
    INPersonHandle *personHandle = contact.personHandle;
    
    NSString *phoneNumber = personHandle.value;
    
    if (_IsPortPBX) {
        
        ExistingSystemDialing = YES;
        
        SystemDialingNum = phoneNumber;
        
        SystemDialingVideo = isVideo;
        
    } else {
        [self makeCall:phoneNumber videoCall:isVideo];
    }
    
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
    
    if (tabBarController.selectedIndex != kTabBarIndex_Recents &&
        _mTabBarSelectedItem == kTabBarIndex_Recents) {
        [self.recentsViewController cleanBadges];
    }
    
    //    if(tabBarController.selectedIndex != kTabBarIndex_Messages &&
    //    _mTabBarSelectedItem == kTabBarIndex_Messages)
    //    {
    //        [self.messagesViewController cleanBadges];
    //    }
    
    [self refreshItemBadge];
    
    _mTabBarSelectedItem = tabBarController.selectedIndex;
}

- (NSUInteger)tabBarControllerSupportedInterfaceOrientations:
(UITabBarController *)tabBarController {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)
tabBarControllerPreferredInterfaceOrientationForPresentation:
(UITabBarController *)tabBarController {
    return UIInterfaceOrientationPortrait;
}

- (HSChatViewController *)chatViewController {
    if (!_chatViewController) {
        _chatViewController =
        [[HSChatViewController alloc] initWithNibName:@"HSChatViewController"
                                               bundle:nil];
        _chatViewController.hidesBottomBarWhenPushed = YES;
    }
    return _chatViewController;
}

//*
- (RecentsViewController *)recentsViewController {
    if (!_recentsViewController) {
        UIStoryboard *stryBoard =
        [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        _recentsViewController = [stryBoard
                                  instantiateViewControllerWithIdentifier:@"RecentViewController"];
    }
    return _recentsViewController;
}

- (SoundService *)soundService {
    if (!_soundService) {
        
        _soundService = [[SoundService alloc] init];
    }
    return _soundService;
}

+ (AppDelegate *)sharedInstance {
    return ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
}

- (long)makeCall:(NSString *)callee videoCall:(BOOL)videoCall {
    NSString *tempcallee;
    NSString *selfnumber;
    if(true){
        tempcallee = [callee getUriUsername:callee] ;
        selfnumber = _account.userName;
    }else{
        selfnumber = [NSString stringWithFormat:@"%@@%@", _account.userName, _account.SIPServer];
        tempcallee =callee;
        
        if ([tempcallee rangeOfString:@"@"].location == NSNotFound) {
            tempcallee = [NSString stringWithFormat:@"%@@%@", tempcallee, _account.SIPServer];
        }
    }
    //[NSString stringWithFormat:@"%@@%@", _account.userName, _account.SIPServer];
    
    NSLog(@"tempcallee=%@", tempcallee);
    
    if ([tempcallee isEqualToString:selfnumber]) {
        
        [self.window makeToast:NSLocalizedString(@"Do not allow to call yourself",
                                                 @"Do not allow to call yourself")
                      duration:1.0
                      position:@"center"];
        
        return INVALID_SESSION_ID;
    }
    
    NSString *CallObject =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"CallObject"];
    
    if ([CallObject rangeOfString:@"@"].location == NSNotFound) {
        
        CallObject =
        [NSString stringWithFormat:@"%@@%@", CallObject, _account.userDomain];
    }
    
    if (_portSIPHandle.registerState != REGISTRATION_OK) { // should register
        // first
        return INVALID_SESSION_ID;
    }
    
#ifdef INPUT_EMAIL_SIGN // shi fou shuru @
    if ([callee rangeOfString:@"@"].location != NSNotFound) {
        
        NSArray *temp = [callee componentsSeparatedByString:@"@"];
        
        if (temp.count > 0) {
            callee = temp[0];
        }
    }
#endif
    
    NSString *callto = [tempcallee stringWithFilterPhoneNumber:tempcallee];
    NSString *displayName = [callee getUriUsername:callee];
    
    Contact *contact = [contactView getContactByPhoneNumber:callto];
    
    if (contact != nil) {
        // If has this contact, use contact display Name.
        displayName = contact.displayName;
    }
    
    NSLog(@"callto=== callto ===%@", callto);
    NSLog(@"displayName====%@", displayName);
    
    long sessionId = [self.callManager makeCall:callto
                                    displayName:displayName
                                      videoCall:videoCall];
    if (sessionId >= 0) {
        HSSession *session = [self.callManager findCallBySessionID:sessionId];
        if (session) {
            
            NSLog(@"session======%@", session);
            [tabBarCtr presentViewController:session.callViewController
                                    animated:NO
                                  completion:nil];
        }
        return sessionId;
    }
    
    return INVALID_SESSION_ID;
}

//
- (void)endCall:(long)sessionId {
    HSSession* session = [self.callManager findCallBySessionID:sessionId];
    if(session){
        [self.callManager endCall:session.uuid];
    }
}

#pragma mark - CallManager delegate
- (void)onIncomingCallWithoutCallKit:(long)sessionId
                         existsVideo:(BOOL)existsVideo
                         remoteParty:(NSString *)remoteParty
                   remoteDisplayName:
(NSString *)
remoteDisplayName { // Call this by CallManager
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    if (session == nil)
        return;
    
    if ([UIApplication sharedApplication].applicationState ==
        UIApplicationStateBackground) {
        // Not support callkit and application Is Background, show the Notification
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        
        if (localNotif) {
            NSString *stringAlert = [NSString
                                     stringWithFormat:@"%@ \n%@",
                                     NSLocalizedString(@"Call from", @"Call from"),
                                     remoteDisplayName];
            if (existsVideo) {
                stringAlert = [NSString
                               stringWithFormat:@"%@ \n%@", NSLocalizedString(@"Video call from",
                                                                              @"Video call from"),
                               remoteDisplayName];
            }
            localNotif.soundName = @"ringtone29.mp3";
            
            localNotif.alertBody = stringAlert;
            localNotif.repeatInterval = 0;
            
            NSDictionary *userInfo = [NSDictionary
                                      dictionaryWithObjectsAndKeys:kNotifKey_IncomingCall, kNotifKey,
                                      [NSNumber numberWithLong:sessionId],
                                      kNotifIncomingCall_SessionId,
                                      [NSNumber numberWithBool:existsVideo],
                                      kNotifIncomingCall_ExistsVideo,
                                      remoteParty,
                                      kNotifIncomingCall_RemoteParty,
                                      remoteDisplayName,
                                      kNotifIncomingCall_RemoteDispalyName,
                                      nil];
            localNotif.userInfo = userInfo;
            session.notification = localNotif;
            [[UIApplication sharedApplication]
             presentLocalNotificationNow:localNotif];
        }
    } else {
        // Not support callkit and application is Active,show the incoming view
        if (!session.callViewController.isViewLoaded) {
            if (session.notification != NULL) {
                session.notification = NULL;
            }
            [tabBarCtr presentViewController:session.callViewController
                                    animated:NO
                                  completion:nil];
        }
    }
}
- (void)onNewOutgoingCall:(long)sessionId {
}

- (void)onAnsweredCall:(long)sessionId {
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    if (session) {
        // If not conference, hold and hide other call.
        if (!self.callManager.isConference && ([self.callManager getConnectCallNum] != 1)) {
            HSSession *oldSession = [self.callManager findAnotherCall:session.sessionId];
            [oldSession.callViewController dismissViewControllerAnimated:NO
                                                              completion:nil];
            [self.callManager holdCall:oldSession.sessionId onHold:YES];
        }
        
        //        [session.callViewController onAnsweredCall:session.outgoing];
        
        [session.callViewController onAnsweredCall:session.outgoing
                                          andvideo:session.videoCall];
    }
}

- (void)delayUnholdCall:(HSSession *)session {
    [self.callManager holdCall:session.sessionId onHold:NO];
}

- (void)onCloseCall:(long)sessionId {
    // call by callmanager, sessionId call has closed
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    if (session) {
        [session.callViewController closeCall];
        if(session.sessionId<0){
            [self refreshMissCall:session];
        }
        [self.callManager removeCall:session];
    }
    
    HSSession *otherSession = [self.callManager findAnotherCall:sessionId];
    if (otherSession != nil) {
        // if has other session, unhold it
        if (otherSession.holdState) { // Unhold a other call.
            //[self.callManager holdCall:otherSession.sessionId onHold:NO];
            // if not use delay call unhold, audio will fail. so must use a delay
            // call.
            [self performSelector:@selector(delayUnholdCall:)
                       withObject:otherSession
                       afterDelay:3];
        }
        if (otherSession.callViewController.mIsConference) { // When a seesion is
            [otherSession.callViewController closeConference];
        }
        
        if ([tabBarCtr respondsToSelector:@selector(presentViewController:
                                                    animated:
                                                    completion:)]) {
            
            if (otherSession.callViewController.isViewLoaded &&
                otherSession.callViewController.view.window) {
                
                NSLog(@"callview is  load");
                
                if ([otherSession.callViewController
                     respondsToSelector:@selector(dismissViewControllerAnimated:
                                                  completion:)]) {
                    
                    [otherSession.callViewController
                     dismissViewControllerAnimated:NO
                     completion:^{
                        
                        [tabBarCtr
                         presentViewController:
                         otherSession.callViewController
                         animated:NO
                         completion:nil];
                        
                    }];
                }
            } else {
                if(!otherSession.callViewController.beingPresented){
                    NSLog(@"callview  is   unPresented");
                    [tabBarCtr presentViewController:otherSession.callViewController
                                            animated:NO
                                          completion:nil];
                }else{
                    NSLog(@"callview  is   unPresented");
                }
            }
        }
    } else { // haven't other session, reset audio route to speaker
        if (![self.soundService
              isBlueToothConnected]) { // haven't BlueTooth,switch to speaker
            shareAppDelegate.audioOutRouteType = 0;
        }
    }
    
    [self deleteremoteVideoView];
    
    if (![shareAppDelegate.callManager getConnectCallNum]) {
        
        BOOL NEEDRegistration =
        [[NSUserDefaults standardUserDefaults] boolForKey:@"NEEDRegistration"];
        
        if (NEEDRegistration) {
            [_portSIPHandle unInitialize];
            [_portSIPHandle registerToServer:_account];
            
            [[NSUserDefaults standardUserDefaults] setBool:NO
                                                    forKey:@"NEEDRegistration"];
        }
    }
    
    if ([UIApplication sharedApplication].applicationState ==
        UIApplicationStateBackground) {
        [self doEnterBackground];
    }
}

- (void)onMuteCall:(long)sessionId muted:(BOOL)muted {
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    if (session) {
        if (session.callViewController) {
            [session.callViewController updateMuteButton:muted];
        }
    }
}

- (void)onHoldCall:(long)sessionId onHold:(BOOL)onHold {
    HSSession *session = [self.callManager findCallBySessionID:sessionId];
    if (session) {
        if (session.callViewController) {
            [session.callViewController updateHoldButton:onHold];
        }
    }
}

- (void)onStopAudio {
    if ([UIApplication sharedApplication].applicationState ==
        UIApplicationStateBackground) {
        [self doEnterBackground];
    }
}

- (void)setAudioOutRoute:(int)outType {
    BOOL hasBlueTooth = [self.soundService isBlueToothConnected];
    // if(_audioOutRouteType != outType)
    {
        if (outType == 0) { // iphone
            if (hasBlueTooth) {
                [self.soundService switchBluetooth:NO];
            }
            [_portSIPHandle setLoudspeakerStatus:NO];
            
        } else if (outType == 1) { // louder speaker
            if (hasBlueTooth) {
                [self.soundService switchBluetooth:NO];
            }
            [_portSIPHandle setLoudspeakerStatus:YES];
        } else if (outType == 2) // bluetooth
        {
            if (hasBlueTooth) {
                [_portSIPHandle setLoudspeakerStatus:NO];
                [self.soundService switchBluetooth:YES];
            }
        }
        
        _audioOutRouteType = outType;
    }
}

- (void)onStartRecord:(long)sessionId {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    int ret = [portSIPEngine startRecord:sessionId
                          recordFilePath:documentsDirectory
                          recordFileName:@"Record"
                         appendTimeStamp:YES
                         audioFileFormat:FILEFORMAT_WAVE
                         audioRecordMode:RECORD_BOTH
                        aviFileCodecType:VIDEO_CODEC_H264
                         videoRecordMode:RECORD_BOTH];

    NSString *fileSTR =
    [[NSBundle mainBundle] pathForResource:@"Onrecorded" ofType:@"wav"];
    
    NSLog(@"record fileSTR===%@", fileSTR);
    
    int ret2 = [portSIPEngine playAudioFileToRemote:sessionId
                                           filename:fileSTR
                                  fileSamplesPerSec:8000
                                               loop:NO];
    
    NSLog(@"ret2===%d", ret2);
    
    //  [self playSoundEffect:fileSTR];
    
    if (ret == 0) {
        MLLog(@"start record success");
    } else {
        MLLog(@"start record fail");
    }
}

- (void)onStopRecord:(long)sessionId {
    int ret = [portSIPEngine stopRecord:sessionId];
    if (ret == 0) {
        
    } else {
        MLLog(@"stop record fail");
    }
}

-(void)tapSmallViewAction:(UITapGestureRecognizer *)recognizer{
    HSSession *session = [self.callManager findCallBySessionID:self.svSessionID];
    
    if(session != nil){
        [self onBackCall:session.uuid];
    }
}

- (void)onBackCall:(NSUUID*)uuid  {
    int num = [self.callManager getConnectCallNum];
    if (num == 0) {
        self.numpadViewController.returnCallButton.alpha = 1;
        return;
    }
    
    HSSession *session = [self.callManager findCallByUUID:uuid];
    
    if(session==nil){//
        session  = [self.callManager findAnotherCall:0xfffff];
        if(session==nil){
            return;
        }
    }
    if ([tabBarCtr respondsToSelector:@selector(presentViewController:
                                                animated:
                                                completion:)]) {
        
        if (session.callViewController.isViewLoaded &&
            session.callViewController.view.window) {

            if ([session.callViewController
                 respondsToSelector:@selector(dismissViewControllerAnimated:
                                              completion:)]) {
                
                [session.callViewController
                 dismissViewControllerAnimated:NO
                 completion:^{
                    
                    [tabBarCtr
                     presentViewController:
                     session.callViewController
                     animated:YES
                     completion:^{
                        self.numpadViewController
                        .returnCallButton.alpha =
                        1;
                    }];
                    
                }];
            }
        } else {
            if(!session.callViewController.beingPresented){
                [tabBarCtr presentViewController:session.callViewController
                                        animated:YES
                                      completion:^{
                    self.numpadViewController.returnCallButton.alpha = 1;}];
                
            }else{
                NSLog(@"callview  is  unPresented");
            }
        }
    }
}

- (void)switchLineFrom:(long)sessionId {
    for (int i = 0; i < MAX_LINES; ++i) {
        HSSession *session = [self.callManager findCallByIndex:i];
        if (session.sessionId != sessionId) {
            [tabBarCtr
             presentViewController:session.callViewController
             animated:YES
             completion:^{
                // self.numpadViewController.returnCallButton.alpha = 1;
                [self.callManager holdCall:session.sessionId onHold:NO];
            }];
            break;
        }
    }
    [self.callManager holdCall:sessionId onHold:YES];
}

- (int)registerWithAccount:(Account *)account {
    if (!_account) {
        _account = account;
    }
    
    _netStatus = [internetReach currentReachabilityStatus];
    int ret = [_portSIPHandle registerToServer:account];
    return ret;
}

#pragma mark - reachabilityChanged
- (void)reachabilityChanged:(NSNotification *)note {
    _netStatus = [internetReach currentReachabilityStatus];
    
    BOOL hasAvailableNetwork = NO;
    if (databaseManage.mOptions.use3G & (_netStatus == ReachableViaWWAN) ||
        _netStatus == ReachableViaWiFi) {
        hasAvailableNetwork = YES;
    }
    
    if (hasAvailableNetwork) {
        [_portSIPHandle unRegister];
        [NSThread sleepForTimeInterval:1.0];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:REGISTER_STATE
         object:REGISTER_STATE_REGISTERING
         userInfo:nil];
        
        [_portSIPHandle registerToServer:_account];
        
    } else {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:REGISTER_STATE
         object:REGISTER_STATE_FAILED
         userInfo:nil];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"setonline"];
    }
}

- (void)startNotifierNetwork {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reachabilityChanged:)
     name:kReachabilityChangedNotification
     object:nil];
    
    [internetReach startNotifier];
}

- (void)stopNotifierNetwork {
    [internetReach stopNotifier];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:kReachabilityChangedNotification
     object:nil];
}

- (void)releaseResource {
    
    NSLog(@"releaseResource releaseResource releaseResource");
    
    [_portSIPHandle loginOut];
    
    [self.soundService stopRingBackTone];
    [self.soundService stopRingTone];
    
    _account = nil;
    
    self.contactViewController = nil;
    self.recentsViewController = nil;
    self.numpadViewController = nil;
    self.messagesViewController = nil;
    self.settingsViewController = nil;
    self.chatViewController = nil;
    self.soundService = nil;
    
    [self stopNotifierNetwork];
}

- (void)closeAllSendVideo {
    for (int i = 0; i < MAX_LINES; i++) {
        HSSession *session = [self.callManager findCallByIndex:i];
        if (session) {
            [_portSIPHandle sendVideo:session.sessionId sendState:NO];
        }
    }
}

- (void)openAllSendVideo {
    for (int i = 0; i < MAX_LINES; i++) {
        HSSession *session = [self.callManager findCallByIndex:i];
        if (session) {
            [_portSIPHandle sendVideo:session.sessionId sendState:YES];
        }
    }
}

#pragma mark - test

- (void)addremoteVideoView:(long)sessid
                  andvideo:(BOOL)isvideo
           andTimeInterval:(NSTimeInterval)starttime;
{
    self.svSessionID = sessid;
    [_SmallView removeFromSuperview];
    
    _SmallView =
    [[UIView alloc] initWithFrame:CGRectMake(ScreenWid - 154, 20, 144, 176)];
    
    _SmallView.backgroundColor = [UIColor clearColor];

    UIApplication *ap = [UIApplication sharedApplication];
    
    [ap.keyWindow addSubview:_SmallView];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(handlePanGesture:)];
    [_SmallView addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapSmallViewAction:)];
    
    _SmallView.userInteractionEnabled = YES;
    [_SmallView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setSessid" object:@(self.svSessionID)];
    
    if (isvideo) {
        
        _SmallLocalView = [[PortSIPVideoRenderView alloc]
                           initWithFrame:CGRectMake(0, 0, 144, 176)];
        
        _SmallLocalView.backgroundColor = [UIColor clearColor];
        
        _SmallLocalView.hidden = YES;
        
        _SmallRemoteView = [[PortSIPVideoRenderView alloc]
                            initWithFrame:CGRectMake(0, 0, 144, 176)];
        
        _SmallRemoteView.backgroundColor = [UIColor clearColor];
        
        [_SmallView addSubview:_SmallRemoteView];
        
        [_SmallRemoteView initVideoRender];
        _SmallRemoteView.contentMode = UIViewContentModeScaleAspectFit;
        [_SmallLocalView initVideoRender];
        
        [portSIPEngine setRemoteVideoWindow:sessid
                          remoteVideoWindow:_SmallRemoteView];
        
        [portSIPEngine setLocalVideoWindow:_SmallLocalView];
#ifdef SDK_MIRROR
        [portSIPEngine displayLocalVideo:NO mirror:NO];
#else
        [portSIPEngine displayLocalVideo:NO];
#endif
        [portSIPEngine sendVideo:sessid sendState:YES];
        
    } else {
        
        [_SmallRemoteView removeFromSuperview];
        [_SmallLocalView removeFromSuperview];
        
        _SmallView.frame = CGRectMake(ScreenWid - 85, 20, 75, 90);
        _SmallView.backgroundColor = RGB(246, 246, 246);
        
        UIImageView *image = [[UIImageView alloc]
                              initWithImage:[UIImage imageNamed:@"oncallcallcall"]];
        
        image.frame = CGRectMake(22, 20, 30, 30);
        
        [_SmallView addSubview:image];
        
        _timeerlab = [[UILabel alloc] init];
        _timeerlab.frame = CGRectMake(0, 60, 75, 30);
        _timeerlab.textColor = MAIN_COLOR;
        _timeerlab.textAlignment = NSTextAlignmentCenter;
        _timeerlab.font = [UIFont systemFontOfSize:11];
        
        [_SmallView addSubview:_timeerlab];
    }
}

- (void)deleteremoteVideoView {
    
    [_SmallView removeFromSuperview];
    
    [_SmallRemoteView removeFromSuperview];
    
    [_SmallLocalView removeFromSuperview];
    
    [_timeerlab removeFromSuperview];
}

- (void)settimelab:(NSString *)timeer {
    if (_timeerlab) {
        _timeerlab.text = timeer;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.window];
    
    CGSize size = _SmallView.bounds.size;
    if (point.x < size.width / 2) {
        point.x = size.width / 2 + 5;
    }
    
    if (point.x > self.window.bounds.size.width - size.width / 2) {
        point.x = self.window.bounds.size.width - size.width / 2 - 5;
    }
    
    if (point.y < size.height / 2) {
        point.y = size.height / 2 + 5;
    }
    
    if (point.y > self.window.bounds.size.height - size.height / 2) {
        point.y = self.window.bounds.size.height - size.height / 2 - 5;
    }
    
    _SmallView.center = point;
}

- (NSString *)getCurrentTimes {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    NSLog(@"currentTimeString =%@", currentTimeString);
    
    return currentTimeString;
}

- (void)productsRequest:(nonnull SKProductsRequest *)request
     didReceiveResponse:(nonnull SKProductsResponse *)response {
}



#pragma mark - file log
- (void)redirectNSLogToDocumentFolder
{
#ifndef DEBUG
    return;
#endif
    if(isatty(STDOUT_FILENO)) {
        return;
    }
    
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.log",dateStr];
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

void UncaughtExceptionHandler(NSException* exception)
{
    NSString* name = [ exception name ];
    NSString* reason = [ exception reason ];
    NSArray* symbols = [ exception callStackSymbols ];
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ];
    for ( NSString* item in symbols )
    {
        [strSymbols appendString: item ];
        [strSymbols appendString: @"\r\n" ];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"UncaughtException.log"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *crashString = [NSString stringWithFormat:@"<- %@ ->[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]\r\n\r\n", dateStr, name, reason, strSymbols];
    
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
}
- (void)onRecvOfflineDialogMessage:(long)messageId fromDisplayName:(NSString *)fromDisplayName from:(NSString *)from toDisplayName:(NSString *)toDisplayName to:(NSString *)to mimeType:(NSString *)mimeType subMimeType:(NSString *)subMimeType messageData:(NSString *)messageData messageTime:(long)time{
    [self onRecvOutOfDialogMessage:fromDisplayName from:from toDisplayName:toDisplayName to:to mimeType:mimeType subMimeType:subMimeType messageData:messageData messageID:messageId messageTime:time];
}

-(long)sendOutOfDialogMessage:(NSString *)sendTo
                     mimeType:(NSString *)mimetype
                  subMimeType:(NSString *)subMimeType
                        isSMS:(bool)smsMessage
                      message:(NSData*)data
                messageLength:(int)dataLength{
    return [self.portSIPHandle sendOutOfDialogMessage:sendTo mimeType:mimetype subMimeType:subMimeType isSMS:NO message:data messageLength:(int)[data length]];
}

#pragma mark OptionsDel
-(bool)enginInit{
    return self.portSIPHandle.SIPInitialized;
}
- (void)setSrtpPolicy:(int)useSRTP{
    [self.portSIPHandle setSrtpPolicy:(SRTP_POLICY)useSRTP];
}
- (void)disableCallForward{
    [self.portSIPHandle disableCallForward];
}
- (void)enableCallForward:(bool)busy ForwardTo:(NSString *)forwardTo{
    [self.portSIPHandle enableCallForward:busy forwardTo:forwardTo];
}
- (void)setRtpPortRange:(int)minArtp maximumRtpAudioPort:(int)maxArtp minimumRtpVideoPort:(int)minVrtp maximumRtpVideoPort:(int)maxVrtp{
    [self.portSIPHandle setRtpPortRange:minArtp maximumRtpAudioPort:maxArtp minimumRtpVideoPort:minVrtp maximumRtpVideoPort:maxVrtp];
}
- (void)enableVAD:(BOOL)state{
    [self.portSIPHandle enableVAD:state];
}
- (void)setEnableCallKit:(BOOL)state{
    [self.callManager setEnableCallKit:state];
}
- (void)enableCNG:(BOOL)state{
    [self.portSIPHandle enableCNG:state];
}
- (void)setPlayDTMFMethod:(int)dtmfOfInfo playDTMFTone:(int)playDtmfTone{
    [self.callManager setPlayDTMFMethod:(DTMF_METHOD)dtmfOfInfo playDTMFTone:playDtmfTone];
}
- (void)setVideoBitrate:(long)sessionid Bitrate:(int)bitrate{
    [self.portSIPHandle setVideoBitrate:sessionid bitrateKbps:bitrate];
}
- (void)setVideoFrameRate:(long)sessionid FrameRate:(int)framerate{
    [self.portSIPHandle setVideoFrameRate:sessionid frameRate:framerate];
}
- (void)setVideoResolution:(int)width Height:(int)heigth{
    [self.portSIPHandle setVideoResolution:width height:heigth];
}
- (void)setVideoNackStatus:(BOOL)state{
    [self.portSIPHandle setVideoNackStatus:state];
}
- (void)addAudioCodec:(int)codec{
    [self.portSIPHandle addAudioCodec:(AUDIOCODEC_TYPE)codec];
}
- (void)addVideoCodec:(int)codec{
    [self.portSIPHandle addVideoCodec:(VIDEOCODEC_TYPE)codec];
}

- (void)clearAudioCodec{
    [self.portSIPHandle clearAudioCodec];
}
- (void)clearVideoCodec{
    [self.portSIPHandle clearVideoCodec];
}
@end
