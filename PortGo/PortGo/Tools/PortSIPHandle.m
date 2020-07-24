//
//  PortSIPHandle.m
//  PortGo
//
//  Created by Joe Lepple on 4/26/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "PortSIPHandle.h"
#import "DataBaseManage.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "URLAsyncGet.h"
#import "AppDelegate.h"

#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>

@interface PortSIPHandle ()
{
    NSTimer *autoRegisterTimer;
    int   autoRegisterRetryTimes;
    
    BOOL _IsAValidAccount;//has registered
}
@end

@implementation PortSIPHandle
@synthesize SIPInitialized;
@synthesize registerState;
@synthesize mAccount;

// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (NSString*)lookupHostIPAddress:(NSString*)ipAddr
{
    const char *ipv4_str = [ipAddr UTF8String];
    const char *ret_addr = NULL;
    struct addrinfo hints, *res, *res0;
    int error;
    char ipv4_str_buf[INET_ADDRSTRLEN] = { 0 };
    char ipv6_str_buf[INET6_ADDRSTRLEN] = { 0 };
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_DEFAULT;
    error = getaddrinfo(ipv4_str, NULL, &hints, &res0);

    for (res = res0; res; res = res->ai_next) {
        if(res->ai_family == AF_INET)
        {
            if( NULL == inet_ntop( AF_INET,
                                  &((struct sockaddr_in *)res->ai_addr)->sin_addr,
                                  ipv4_str_buf,
                                  sizeof(ipv4_str_buf) )
               ) {
                continue;
            }
            
            ret_addr = ipv4_str_buf;
            NSLog(@"IPV4 address %d = %s", 0, ipv4_str_buf);
        }
        else if(res->ai_family == AF_INET6)
        {
            if( NULL == inet_ntop( AF_INET6,
                                  &((struct sockaddr_in6 *)res->ai_addr)->sin6_addr,
                                  ipv6_str_buf,
                                  sizeof(ipv6_str_buf) )
               ) {
                continue;
            }
            
            ret_addr = ipv6_str_buf;
            
            NSLog(@"IPV6 address %d = %s", 0, ipv6_str_buf);
        }
        break;
    }
    freeaddrinfo(res0);
    
    if(ret_addr == NULL)
    {
        return ipAddr;
    }
    
    return [NSString stringWithFormat:@"%s", ret_addr];
}



- (BOOL)hasActiveAccount
{
    if([databaseManage selectActiveAccount])
        return YES;
    
    return NO;
}

- (int) registerToServer:(Account*)account
{
    //check has available network
    BOOL hasAvailableNetwork = NO;
    if(databaseManage.mOptions.use3G & (shareAppDelegate.netStatus == ReachableViaWWAN) ||
       databaseManage.mOptions.useWIFI & (shareAppDelegate.netStatus == ReachableViaWiFi))
    {
        hasAvailableNetwork = YES;
    }

    mAccount = account;
    
    if(SIPInitialized)
    {
        [super unInitialize];
        SIPInitialized = NO;
    }
    
    if(hasAvailableNetwork)
    {
        if(mAccount)
        {
            //随机本地端口
            int localSIPPort = arc4random()%7000+8000;//8k-15k
            NSString* loaclIPaddress = @"::";
            
            TRANSPORT_TYPE transPort = TRANSPORT_UDP;
            
            if ([mAccount.transportType isEqualToString:@"TLS"]) {
                transPort = TRANSPORT_TLS;
                loaclIPaddress = [self getLocalIpAddress:0];
            }else if([mAccount.transportType isEqualToString:@"TCP"]){
                transPort = TRANSPORT_TCP;
                loaclIPaddress = [self getLocalIpAddress:0];
            }else if([mAccount.transportType isEqualToString:@"PERS_UDP"]){
                transPort = TRANSPORT_PERS_UDP;
            }
            else if([mAccount.transportType isEqualToString:@"PERS_TCP"]){
                transPort = TRANSPORT_PERS_TCP;
            }
                        
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            PORTSIP_LOG_LEVEL logLevel = PORTSIP_LOG_NONE;
            
            if (mAccount.isOpenlog == YES){
#ifdef DEBUG
                logLevel = PORTSIP_LOG_DEBUG;
#else
                logLevel = PORTSIP_LOG_DEBUG;
#endif
            }
            
            int ret = [self initialize:transPort localIP:loaclIPaddress localSIPPort:localSIPPort loglevel:logLevel logPath:documentsDirectory maxLine:8 agent:USER_AGENT  audioDeviceLayer:0 videoDeviceLayer:0 TLSCertificatesRootPath:@"" TLSCipherList:@"" verifyTLSCertificate:account.useCert];
            NSLog(@"SDK initialize localSIPPort=%d ",localSIPPort);
            if(ret != 0)
            {
                MLLog(@"initializeSDK failure ErrorCode = %d",ret);
                return -1;
            }
            
            NSString *stunServer = @"";
            int stunPort = 0;
            if (databaseManage.mAccount.enableSTUN) {
                stunServer = databaseManage.mAccount.STUNServer;
                stunPort = databaseManage.mAccount.STUNPort;
            }

            ret = [self setUser:mAccount.userName
                    displayName:mAccount.displayName
                       authName:mAccount.authName
                       password:mAccount.password
                     userDomain:mAccount.userDomain
                      SIPServer:mAccount.SIPServer.length==0?mAccount.userDomain:mAccount.SIPServer
                  SIPServerPort:mAccount.SIPServerPort
                     STUNServer:stunServer
                 STUNServerPort:stunPort
                 outboundServer:mAccount.outboundServer
             outboundServerPort:mAccount.outboundServerPort];
            
            NSLog(@"setUser userName=%@  displayName=%@  authName=%@  password=%@  userDomain=%@  SIPServer=%@  SIPServerPort=%d  stunServer=%@  stunPort=%d  outboundServer=%@      outboundServerPort=%d",mAccount.userName,mAccount.displayName,mAccount.authName,mAccount.password,mAccount.userDomain,mAccount.SIPServer,mAccount.SIPServerPort,stunServer,stunPort,mAccount.outboundServer,mAccount.outboundServerPort);
            
            
            
            if(ret != 0)
            {
                MLLog(@"setUser failure ErrorCode = %d",ret);
                return -1;
            }

            [self setInstanceId:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
            
            [self enable3GppTags:false];
            [portSIPEngine  enableAutoCheckMwi:YES];
            
            if (databaseManage.mAccount.presenceAgent == 1) {
                [self setPresenceMode:1];
            } else {
                [self setPresenceMode:0];
            }
            
            if(databaseManage.mOptions.useSRTP != SRTP_POLICY_NONE)
            {
                [self setSrtpPolicy:databaseManage.mOptions.useSRTP];
            }
            
            [shareAppDelegate  addPushSupportWithPortPBX:YES];
            
            // Try to register the default identity
            int nRegister = [super registerServer:90 retryTimes:0];
            
            SIPInitialized = YES;
            registerState = REGISTRATION_INPROGRESS;
            [[NSNotificationCenter defaultCenter] postNotificationName:REGISTER_STATE object:REGISTER_STATE_REGISTERING userInfo:nil];
            databaseManage.opratorDel = shareAppDelegate;
            [databaseManage loadAVOptions];
            [databaseManage loadNetworkOptions];
            //default use front camera
            [self setVideoDeviceId:1];
            if(transPort == TRANSPORT_TLS || transPort == TRANSPORT_TCP){
                [self setKeepAliveTime:0];
            }
            
            return nRegister;
        }
        else//Not Active Account
        {
            return -2;
        }
    }
    else{//hasAvailableNetwork
        MLLog(@"Haven't Available Network");
        return -3;
    }
    return 0;
}

- (void) loginOut
{
    if (autoRegisterTimer != nil){
        //if reregister is start, remove it
        [autoRegisterTimer invalidate];
        autoRegisterTimer = nil;
        MLLog(@"stop autoRegisterTimer");
    }
    

    
    if(SIPInitialized)
    {
        [shareAppDelegate  addPushSupportWithPortPBX:NO];
        [super unRegisterServer];
         MLLog(@"unRegisterServer");
        //[NSThread sleepForTimeInterval:3.0];
        //[super unInitialize];
        
        registerState = REGISTRATION_NONE;

        //SIPInitialized = NO;
    }
    _IsAValidAccount = NO;
}

- (NSString*)getAccountSIPUri
{
    if(mAccount)
    {
        NSString* sipUri = [[NSString alloc] initWithFormat:@"%@@%@:%d",
                            mAccount.userName,
                            (mAccount.userDomain == nil || mAccount.userDomain.length <= 0)? mAccount.SIPServer: mAccount.userDomain,
                            mAccount.SIPServerPort];
        return sipUri;
    }
    return nil;
}

- (void)refreshRegister
{
    switch (registerState) {
        case REGISTRATION_NONE:
            //Not Register
            break;
        case REGISTRATION_INPROGRESS:
            //is registering
            break;
        case REGISTRATION_OK:
            //has registered, refreshRegistration
            [self refreshRegistration:0];
            NSLog(@"Refresh Registration...");
            break;
        case REGISTRATION_FAILE:
            NSLog(@"retry a new register");
            //Register Failure
            /*
            [self unRegisterServer];
            [super registerServer:90 retryTimes:0];
            
            SIPInitialized = YES;
            registerState = REGISTRATION_INPROGRESS;
            [[NSNotificationCenter defaultCenter] postNotificationName:REGISTER_STATE object:REGISTER_STATE_REGISTERING userInfo:nil];*/
            
            
            if (![shareAppDelegate.callManager getConnectCallNum]){
                
                [self unInitialize];
                [self registerToServer:mAccount];
                
            }else
            {
                //NEEDRegistration 通话时网络切换  挂断后需要重新注册
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"NEEDRegistration"];
                   [self refreshRegistration:0];
                
            }
            
         
            
            
        default:
            break;
    }
}

- (void) unRegister
{
    if(registerState == REGISTRATION_INPROGRESS||registerState == REGISTRATION_OK){
        [self unRegisterServer];

        NSLog(@"unRegister when background");
        registerState = REGISTRATION_FAILE;
        //[[NSNotificationCenter defaultCenter] postNotificationName:REGISTER_STATE object:REGISTER_STATE_FAILED userInfo:nil];
    }
}

- (void)onRegisterSuccess:(int)statusCode withStatusText:(char*) statusText
{
    registerState = REGISTRATION_OK;
    [[NSNotificationCenter defaultCenter] postNotificationName:REGISTER_STATE object:REGISTER_STATE_SUCCESS userInfo:nil];
    autoRegisterRetryTimes = 0;
    _IsAValidAccount = YES;
    MLLog(@"onRegisterSuccess statusCode:%d(%s)", statusCode, statusText);
    
   // [setView showonline:YES];
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"setonline"];
    
}


- (void)onRegisterFailure:(int)statusCode withStatusText:(char*) statusText
{
    registerState = REGISTRATION_FAILE;
    NSDictionary *userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:(const char *)statusText], @"statusText", @(statusCode), @"errorCode", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:REGISTER_STATE object:REGISTER_STATE_FAILED userInfo:userInfoDict];
    
     [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"setonline"];
    
    
    if(_IsAValidAccount){
        
        //If the NetworkStatus not change, received onRegisterFailure event. can added a atuo reRegister Timer like this:
        // added a atuo reRegister Timer
        int interval = autoRegisterRetryTimes * 2 + 1;
        //max interval is 60
        interval = interval > 60?60:interval;
        autoRegisterRetryTimes ++;
        autoRegisterTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(refreshRegister) userInfo:nil repeats:NO];
    }
    
    MLLog(@"onRegisterFailure statusCode:%d(%s)", statusCode, statusText);

}
@end
