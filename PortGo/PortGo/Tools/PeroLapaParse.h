//
//  PeroLapaParse.h
//  PortGo
//
//  Created by XuYifang on 6/24/15.
//  Copyright (c) 2015 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeroLapaParse : NSObject{
    NSString* sip_server;
    NSString* sip_port;
    NSString* home_url;
    NSString* transport;
    NSString* stun;
    NSString* stun_server;
    NSString* stun_port;
}

@property(readonly) NSString* sip_server;
@property(readonly) NSString* sip_port;
@property(readonly) NSString* home_url;
@property(readonly) NSString* transport;
@property(readonly) NSString* stun;
@property(readonly) NSString* stun_server;
@property(readonly) NSString* stun_port;

- (BOOL) doParse:(NSString *)data;
- (void) doParseAVCodec:(NSString *)data;
@end
