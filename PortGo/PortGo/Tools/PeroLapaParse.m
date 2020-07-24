//
//  PeroLapaParse.m
//  PortGo
//
//  Created by XuYifang on 6/24/15.
//  Copyright (c) 2015 PortSIP Solutions, Inc. All rights reserved.
//

#import "PeroLapaParse.h"
#import "AppDelegate.h"

@implementation PeroLapaParse
@synthesize sip_server;
@synthesize sip_port;
@synthesize home_url;
@synthesize transport;
@synthesize stun;
@synthesize stun_server;
@synthesize stun_port;

-(void)addCodec:(NSString*)codeName
{
    NSString* lccodeName = [codeName lowercaseString];
    if([lccodeName hasPrefix:@"g722"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_G722)];
    else if([lccodeName hasPrefix:@"g729"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_G729)];
    else if([lccodeName hasPrefix:@"pcma"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_PCMA)];
    else if([lccodeName hasPrefix:@"pcmu"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_PCMU)];
    else if([lccodeName hasPrefix:@"gsm"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_GSM)];
    else if([lccodeName hasPrefix:@"amr"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_AMR)];
    else if([lccodeName hasPrefix:@"amrwb"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_AMRWB)];
    else if([lccodeName hasPrefix:@"ilbc"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_ILBC)];
    else if([lccodeName hasPrefix:@"speex"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_SPEEX)];
    else if([lccodeName hasPrefix:@"speexwb"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_SPEEXWB)];
    else if([lccodeName hasPrefix:@"opus"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_OPUS)];
    
    if([lccodeName hasPrefix:@"h263"])
        [portSIPEngine addVideoCodec:VIDEO_CODEC_H263];
    else if([lccodeName hasPrefix:@"h263＋"])
        [portSIPEngine addVideoCodec:VIDEO_CODEC_H263_1998];
    else if([lccodeName hasPrefix:@"h264"])
        [portSIPEngine addVideoCodec:VIDEO_CODEC_H264];
    else if([lccodeName hasPrefix:@"vp8"])
        [portSIPEngine addVideoCodec:VIDEO_CODEC_H264];
    
}

- (BOOL) doParse:(NSString *)data{
    NSArray *components=[data componentsSeparatedByString:@"<br/>"];
    
    [portSIPEngine clearAudioCodec];
    [portSIPEngine clearVideoCodec];
    BOOL isValid = false;
    
    for (int i = 0; i < [components count]; i++) {
        NSArray *item = [[components objectAtIndex:i] componentsSeparatedByString:@"="];
        if ([item count]<2) {
            continue;
        }
        /*
         transport=tcp  //support tcp/udp/tls/pers
         tlsenable=no //remove it, transport is ok.
         voice_codec=g729 //support g729/pcma/pcmu/gsm/isac/amr/amrwb/speex/speexwb
         video_codec=h264 //support h263/h263+/h264/vp8
         */
        
        if ([[item objectAtIndex:0] isEqualToString:@"sip_server"]) {
            sip_server = [item objectAtIndex:1];
            isValid = true;
        }else if([[item objectAtIndex:0] isEqualToString:@"port"]) {
            sip_port = [item objectAtIndex:1];
        }else if([[item objectAtIndex:0] isEqualToString:@"home_url"]) {
            home_url = [item objectAtIndex:1];
        }else if([[item objectAtIndex:0] isEqualToString:@"transport"]) {
             transport = @"UDP";
            if([[item objectAtIndex:1] isEqualToString:@"tcp"]){
                transport = @"TCP";
            }else if([[item objectAtIndex:1] isEqualToString:@"udp"]){
                transport = @"UDP";
            }else if([[item objectAtIndex:1] isEqualToString:@"tls"]){
                transport = @"TLS";
            }else if([[item objectAtIndex:1] isEqualToString:@"pers"]){
                transport = @"PERS";
            }
        }else if([[item objectAtIndex:0] isEqualToString:@"stun"]) {
            stun = [item objectAtIndex:1];
        }else if([[item objectAtIndex:0] isEqualToString:@"stun_server"]) {
            stun_server = [item objectAtIndex:1];
        }else if([[item objectAtIndex:0] isEqualToString:@"stun_port"]) {
            stun_port = [item objectAtIndex:1];
        }
    }
    return isValid;
};

- (void) doParseAVCodec:(NSString *)data
{
    NSArray *components=[data componentsSeparatedByString:@"<br/>"];
    
    for (int i = 0; i < [components count]; i++) {
        NSArray *item = [[components objectAtIndex:i] componentsSeparatedByString:@"="];
        if ([item count]<2) {
            continue;
        }
        /*
         transport=tcp  //support tcp/udp/tls/pers
         tlsenable=no //remove it, transport is ok.
         voice_codec=g729 //support g729/pcma/pcmu/gsm/isac/amr/amrwb/speex/speexwb
         video_codec=h264 //support h263/h263+/h264/vp8
         */
        
        if([[item objectAtIndex:0] isEqualToString:@"dtmfmode"]) {
            if([[item objectAtIndex:1] isEqualToString:@"rfc2833"]){
                databaseManage.mOptions.dtmfOfInfo = DTMF_RFC2833;
            }else if([[item objectAtIndex:1] isEqualToString:@"info"]){
                databaseManage.mOptions.dtmfOfInfo = DTMF_INFO;
            }
        }else if([[item objectAtIndex:0] isEqualToString:@"voice_codec"]) {
            [self addCodec:[item objectAtIndex:1]];
        }else if([[item objectAtIndex:0] isEqualToString:@"video_codec"]) {
            [self addCodec:[item objectAtIndex:1]];
        }
    }
}
@end
