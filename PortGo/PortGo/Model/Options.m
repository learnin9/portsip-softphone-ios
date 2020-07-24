//
//  Options.m
//  PortGo
//
//  Created by Joe Lepple on 5/30/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "Options.h"
#import <UIKit/UIDevice.h>


@implementation Options
@synthesize SIPTransport;
@synthesize use3G;
@synthesize forceBackground;
@synthesize enableCallKit;
@synthesize useWIFI;
@synthesize autoReg;

@synthesize voice_mail;

//STUN
@synthesize enableSTUN;
@synthesize STUNServer;
@synthesize STUNPort;

//IM And Presence
@synthesize presenceAgent;
@synthesize publishRefresh;
@synthesize subscribeRefresh;

//Cert
@synthesize useCert;

//audio Features
@synthesize enableVAD;
@synthesize enableCNG;

//video Features
@synthesize videoBandwidth;
@synthesize videoFrameRate;
@synthesize videoResolution;
@synthesize videoNACK;

//Audio codec
@synthesize codecG722;
@synthesize codecG729;
@synthesize codecAMR;
@synthesize codecAMRwb;
@synthesize codecGSM;
@synthesize codecPCMA;
@synthesize codecPCMU;
@synthesize codecILBC;
@synthesize codecSpeexNB;
@synthesize codecSpeexWB;
@synthesize codecOPUS;

//Video codec
@synthesize codecH263;
@synthesize codecH263_1998;
@synthesize codecH264;
@synthesize codecVP8;
@synthesize codecVP9;
//audio Features

- (void)setUseSRTP:(int)useSRTP
{
    _useSRTP = useSRTP;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
    {
        [self.opratorDelegate setSrtpPolicy:_useSRTP];
    }
}

- (void)setEnableForward:(int)enableForward
{
    _enableForward = enableForward;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit]&& !_enableForward)
    {
        [self.opratorDelegate disableCallForward];
    }
}

- (void)setForwardTo:(NSString *)forwardTo
{
    _forwardTo = forwardTo;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit]&&_enableForward)
    {
        [self.opratorDelegate enableCallForward:NO ForwardTo:_forwardTo];
    }
}

- (void)setRtpPortFrom:(int)rtpPortFrom
{
    _rtpPortFrom = rtpPortFrom;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
   {
       
        int minArtp = _rtpPortFrom;
        int maxArtp = minArtp + 5000;
        int minVrtp = maxArtp + 2;
        int maxVrtp = minVrtp + 5000;
       [self.opratorDelegate setRtpPortRange:minArtp maximumRtpAudioPort:maxArtp minimumRtpVideoPort:minVrtp maximumRtpVideoPort:maxVrtp];
    }
}

- (int)enableVAD
{
    return enableVAD;
}

- (void)setEnableVAD:(int)newValue
{
    enableVAD = newValue;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
    {
        [self.opratorDelegate enableVAD:newValue>0];
    }
}
//返回设置的值，不支持的区域或者版本
- (int)enableCallKit
{
    return enableCallKit;
}

//设置值，不支持的区域或者版本，无法改变，始终为false
- (void)setEnableCallKit:(int)newValue
{
    if([self supportCallKit]){
        enableCallKit = newValue;
    }else{
        enableCallKit = 0;
    }

    BOOL enable =  (enableCallKit != 0);
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
    {
       [self.opratorDelegate setEnableCallKit:enable];
    }
}

//ios版本，区域是否支持。>10.0 非中国区返回true，否则
-(BOOL)supportCallKit{
    BOOL support;
    #ifdef NOT_SUPPORT_CALL_KIT
            support = NO;
    
//            NSInteger   tempEnableCallKitSwich  = [[NSUserDefaults standardUserDefaults]integerForKey:@"tempEnableCallKitSwich"];

    #else
            //NSString *localeLanguageCode = [[[NSBundle mainBundle] preferredLocalizations] firstObject];//语言设置

    if (@available(iOS 10.0, *)) {
        NSLocale *userLocale = [NSLocale currentLocale];
        if ([userLocale.countryCode containsString: @"CN"] || [userLocale.countryCode containsString: @"CHN"]) {
            NSLog(@"currentLocale is China so we cannot use CallKit.");
            support = NO;
        } else {
            support = YES;
        }
    } else {
        // Fallback on earlier versions
        support = NO;
    }
    #endif
    
    return support;
}

- (int)enableCNG
{
    return enableCNG;
}

- (void)setEnableCNG:(int)newValue
{
    enableCNG = newValue;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
    {
        [self.opratorDelegate enableCNG:newValue>0];
    }
}



- (int)dtmfOfInfo
{
    return dtmfOfInfo;
}
- (void)setDtmfOfInfo:(int)newValue
{
    dtmfOfInfo = newValue;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
    {
        [self.opratorDelegate setPlayDTMFMethod:dtmfOfInfo playDTMFTone:playDtmfTone];
    }
}

- (int)playDtmfTone
{
    return playDtmfTone;
}
- (void)setPlayDtmfTone:(int)newValue
{
    playDtmfTone = newValue;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
    {
        [self.opratorDelegate setPlayDTMFMethod:dtmfOfInfo playDTMFTone:playDtmfTone];
    }
}

//video Features
- (int)videoBandwidth
{
    return videoBandwidth;
}
- (void)setVideoBandwidth:(int)newValue
{
    videoBandwidth = newValue;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
    {
        [self.opratorDelegate setVideoBitrate:-1 Bitrate:newValue];
    }
}

- (int)videoFrameRate
{
    return videoFrameRate;
}
- (void)setVideoFrameRate:(int)newValue
{
    videoFrameRate = newValue;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
    {
    [self.opratorDelegate setVideoFrameRate:-1 FrameRate:newValue];
    }
}

- (int)videoResolution
{
    return videoResolution;
}
- (void)setVideoResolution:(int)newValue
{
    //(VIDEO_RESOLUTION)
    videoResolution = newValue;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
    {
        int width = 352;
        int height = 288;
        //QCIF (176*144)", @"CIF (352*288)", @"720P (1280*720)//
        switch (newValue) {
            case 0:
                width = 176;
                height = 144;
                break;
            case 1:
                width = 352;
                height = 288;
                break;
            case 2:
                width = 1280;
                height = 720;
                break;
            default:
                break;
        }

        [self.opratorDelegate setVideoResolution:width Height:height];

    }
}
- (int)videoNACK
{
    return videoNACK;
}

- (void)setVideoNACK:(int)newValue
{
    videoNACK = newValue;
    if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
    {
        [self.opratorDelegate setVideoNackStatus:newValue];
    }
}


- (void)setAudioVideoCodec
{
if(self.opratorDelegate!=nil&&[self.opratorDelegate enginInit])
{
    [self.opratorDelegate clearAudioCodec];
   
        if(codecOPUS)
            [self.opratorDelegate addAudioCodec:105];//AUDIOCODEC_OPUS = 105

        if(codecG729)
            [self.opratorDelegate addAudioCodec:18];//AUDIOCODEC_G729  = 18
        if(codecPCMA)
            [self.opratorDelegate addAudioCodec:8];//AUDIOCODEC_PCMA = 8
        if(codecPCMU)
            [self.opratorDelegate addAudioCodec:0];//AUDIOCODEC_PCMU = 0
        if(codecGSM)
            [self.opratorDelegate addAudioCodec:3];//AUDIOCODEC_GSM = 3
        if(codecAMR)
            [self.opratorDelegate addAudioCodec:98];//AUDIOCODEC_AMR = 98
        if(codecAMRwb)
            [self.opratorDelegate addAudioCodec:99];//AUDIOCODEC_AMRWB = 99
        if(codecILBC)
            [self.opratorDelegate addAudioCodec:97];//AUDIOCODEC_ILBC= 97
        if(codecSpeexNB)
            [self.opratorDelegate addAudioCodec:100];//AUDIOCODEC_SPEEX= 100
        if(codecSpeexWB)
            [self.opratorDelegate addAudioCodec:102];//AUDIOCODEC_SPEEXWB = 102

        if(codecG722)
            [self.opratorDelegate addAudioCodec:9];//AUDIOCODEC_G722 = 9

        [self.opratorDelegate clearVideoCodec];
        
    /// Video codec type
        if(codecH264){
            [self.opratorDelegate addVideoCodec:125];//VIDEO_CODEC_H264 = 125
        }
        if (codecVP8) {
            [self.opratorDelegate addVideoCodec:120];//VIDEO_CODEC_VP8 = 120
        }
        if (codecVP9) {
            [self.opratorDelegate addVideoCodec:122];//VIDEO_CODEC_VP9 = 122
        }
    }
}
@end
