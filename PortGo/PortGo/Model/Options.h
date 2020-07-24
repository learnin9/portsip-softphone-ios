//
//  Options.h
//  PortGo
//
//  Created by Joe Lepple on 5/30/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol OptionOperatorDelegate<NSObject>
-(bool)enginInit;
- (void)setSrtpPolicy:(int)useSRTP;
- (void)disableCallForward;
- (void)enableCallForward:(bool)busy ForwardTo:(NSString *)forwardTo;
- (void)setRtpPortRange:(int)minArtp maximumRtpAudioPort:(int)maxArtp minimumRtpVideoPort:(int)minVrtp maximumRtpVideoPort:(int)maxVrtp;
- (void)enableVAD:(BOOL)state;
- (void)setEnableCallKit:(BOOL)state;
- (void)enableCNG:(BOOL)state;
- (void)setPlayDTMFMethod:(int)dtmfOfInfo playDTMFTone:(int)playDtmfTone;
- (void)setVideoBitrate:(long)sessionid Bitrate:(int)newValue;
- (void)setVideoFrameRate:(long)sessionid FrameRate:(int)newValue;
- (void)setVideoResolution:(int)width Height:(int)heigth;
- (void)setVideoNackStatus:(BOOL)state;
- (void)addAudioCodec:(int)codec;
- (void)addVideoCodec:(int)codec;
- (void)clearAudioCodec;
- (void)clearVideoCodec;
@end

@interface Options : NSObject{
@private
    int SIPTransport;
    int use3G;
    int forceBackground;
    int enableCallKit;
    int useWIFI;
    int autoReg;
    
    NSString* voice_mail;
    
    //STUN
    int enableSTUN;
    NSString* STUNServer;
    int  STUNPort;
    
    //IM And Presence
    int presenceAgent;
    int publishRefresh;
    int subscribeRefresh;
    
    //Cert
    int useCert;
    
    //audio Features
    int enableVAD;
    int dtmfOfInfo;
    int playDtmfTone;
    
    //video Features
    int videoBandwidth;
    int videoFrameRate;
    int videoResolution;
    int videoNACK;
    
    //Audio codec
    int codecG722;
    int codecG729;
    int codecAMR;
    int codecAMRwb;
    int codecGSM;
    int codecPCMA;
    int codecPCMU;
    int codecILBC;
    int codecSpeexNB;
    int codecSpeexWB;
    int codecOPUS;

    //Video codec
    int codecH263;
    int codecH263_1998;
    int codecH264;
    int codecVP8;
    int codecVP9;
}

@property (nonatomic,weak)id<OptionOperatorDelegate> opratorDelegate;
@property int SIPTransport;
@property int use3G;
@property int forceBackground;
@property int enableCallKit;
@property int useWIFI;
@property int autoReg;
@property (nonatomic, assign) int useSRTP;

@property (nonatomic, copy) NSString *voice_mail;

@property int enableSTUN;
@property (nonatomic,retain) NSString *STUNServer;
@property int STUNPort;

@property int presenceAgent;
@property int publishRefresh;
@property int subscribeRefresh;

@property int useCert;

@property (nonatomic, assign) int enableForward;
@property (nonatomic, copy) NSString *forwardTo;

//Audio Features
@property(nonatomic, assign) int rtpPortFrom;

@property int enableVAD;
@property int enableCNG;
@property int dtmfOfInfo;
@property int playDtmfTone;

//video Feature
@property int videoBandwidth;
@property int videoFrameRate;
@property int videoResolution;
@property int videoNACK;

//Audio codec
@property int codecG722;
@property int codecG729;
@property int codecAMR;
@property int codecAMRwb;
@property int codecGSM;
@property int codecPCMA;
@property int codecPCMU;
@property int codecILBC;
@property int codecSpeexNB;
@property int codecSpeexWB;
@property int codecOPUS;

//Video codec
@property int codecH263;
@property int codecH263_1998;
@property int codecH264;
@property int codecVP8;
@property int codecVP9;

//badge
@property int mCallBadge;//未查阅的呼叫的消息条数
@property int mMsgBadge;//订阅的未处理消息条数

- (void)setAudioVideoCodec;
- (BOOL)supportCallKit;
@end
