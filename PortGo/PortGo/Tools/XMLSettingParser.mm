//
//  URLAsyncGet.m
//
//  Created by Joe Lepple on 4/12/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. . All rights reserved.
//

#import "XMLSettingParser.h"
#import "PortMD5.hxx"
#import "AppDelegate.h"

@implementation XMLSettingParser
@synthesize audiocodec1;
@synthesize audiocodec2;
@synthesize audiocodec3;
@synthesize audiocodec4;
@synthesize audiocodec5;
@synthesize audiocodec6;
@synthesize audiocodec7;
@synthesize audiocodec8;

@synthesize serverip1;
@synthesize serverport1;
@synthesize serverip2;
@synthesize serverport2;

@synthesize dialerversion;
@synthesize updateavailable;

@synthesize vad;
@synthesize cng;

@synthesize host;
@synthesize url;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(!currentElementValue)
        currentElementValue = [[NSString alloc] init];
    
    currentElementValue = [NSString stringWithFormat:@"%@",string];
}

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
    else if([lccodeName hasPrefix:@"speexwb"]||[lccodeName hasPrefix:@"speex wb"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_SPEEXWB)];
    else if([lccodeName hasPrefix:@"opus"])
        [portSIPEngine addAudioCodec:(AUDIOCODEC_OPUS)];

    if([lccodeName hasPrefix:@"h263"])
        [portSIPEngine addVideoCodec:VIDEO_CODEC_H263];
    else if([lccodeName hasPrefix:@"h2631998"])
        [portSIPEngine addVideoCodec:VIDEO_CODEC_H263_1998];
    else if([lccodeName hasPrefix:@"h264"])
        [portSIPEngine addVideoCodec:VIDEO_CODEC_H264];

}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"audiocodec1"]) {
        audiocodec1 = currentElementValue;
        [self addCodec:currentElementValue];
	}else if([elementName isEqualToString:@"audiocodec2"]) {
        audiocodec2 = currentElementValue;
        [self addCodec:currentElementValue];
	}else if([elementName isEqualToString:@"audiocodec3"]) {
        audiocodec3 = currentElementValue;
        [self addCodec:currentElementValue];
	}else if([elementName isEqualToString:@"audiocodec4"]) {
        audiocodec4 = currentElementValue;
        [self addCodec:currentElementValue];
	}else if([elementName isEqualToString:@"audiocodec5"]) {
        audiocodec5 = currentElementValue;
        [self addCodec:currentElementValue];
	}else if([elementName isEqualToString:@"audiocodec6"]) {
        audiocodec6 = currentElementValue;
        [self addCodec:currentElementValue];
	}else if([elementName isEqualToString:@"audiocodec7"]) {
        audiocodec7 = currentElementValue;
        [self addCodec:currentElementValue];
	}else if([elementName isEqualToString:@"audiocodec8"]) {
        audiocodec8 = currentElementValue;
        [self addCodec:currentElementValue];
	}else if([elementName isEqualToString:@"serverip1"]) {
        serverip1 = currentElementValue;
	}else if([elementName isEqualToString:@"serverport1"]) {
        serverport1 = currentElementValue;
	}else if([elementName isEqualToString:@"serverip2"]) {
        serverip2 = currentElementValue;
	}else if([elementName isEqualToString:@"serverport2"]) {
        serverport2 = currentElementValue;
	}else if([elementName isEqualToString:@"dialerversion"]) {
        dialerversion = currentElementValue;
	}else if([elementName isEqualToString:@"updateavailable"]) {
        updateavailable = currentElementValue;
	}else if([elementName isEqualToString:@"vad"]) {
        vad = currentElementValue;
        if([vad isEqualToString:@"False"]){
            [portSIPEngine enableVAD:NO];
        }
        else
        {
            [portSIPEngine enableVAD:YES];
        }
	}else if([elementName isEqualToString:@"cng"]) {
        cng = currentElementValue;
        if([cng isEqualToString:@"False"]){
            [portSIPEngine enableCNG:NO];
        }
        else
        {
            [portSIPEngine enableCNG:YES];
        }
	}else if([elementName isEqualToString:@"host"]) {
        host = currentElementValue;
	}else if([elementName isEqualToString:@"url"]) {
        url = currentElementValue;
	}
}

- (void) doParse:(NSData *)data
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser setDelegate:self];
    
    [portSIPEngine clearAudioCodec];
    [portSIPEngine clearVideoCodec];
    
    [parser parse];
    
}
@end
