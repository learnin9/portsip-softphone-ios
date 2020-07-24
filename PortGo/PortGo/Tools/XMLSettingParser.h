//
//  URLAsyncGet.h
//
//  Created by Joe Lepple on 4/12/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLSettingParser : NSObject <NSXMLParserDelegate>{
    NSString* currentElementValue;
    
    NSString* audiocodec1;
    NSString* audiocodec2;
    NSString* audiocodec3;
    NSString* audiocodec4;
    NSString* audiocodec5;
    NSString* audiocodec6;
    NSString* audiocodec7;
    NSString* audiocodec8;
    
    NSString* serverip1;
    NSString* serverport1;
    NSString* serverip2;
    NSString* serverport2;
    
    NSString* dialerversion;
    NSString* updateavailable;
    
    NSString* vad;
    NSString* cng;
    
    NSString* host;
    NSString* url;
}

@property(readonly) NSString* audiocodec1;
@property(readonly) NSString* audiocodec2;
@property(readonly) NSString* audiocodec3;
@property(readonly) NSString* audiocodec4;
@property(readonly) NSString* audiocodec5;
@property(readonly) NSString* audiocodec6;
@property(readonly) NSString* audiocodec7;
@property(readonly) NSString* audiocodec8;

@property(readonly) NSString* serverip1;
@property(readonly) NSString* serverport1;
@property(readonly) NSString* serverip2;
@property(readonly) NSString* serverport2;

@property(readonly) NSString* dialerversion;
@property(readonly) NSString* updateavailable;

@property(readonly) NSString* vad;
@property(readonly) NSString* cng;

@property(readonly) NSString* host;
@property(readonly) NSString* url;

- (void) doParse:(NSData *)data;
@end
