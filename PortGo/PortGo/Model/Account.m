//
//  Account.m
//  PortGo
//
//  Created by Joe Lepple on 3/26/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "Account.h"
#import "constatnts.h"

@implementation Account
@synthesize   accountId = mAccountId;
@synthesize   userName = mUserName;
@synthesize   displayName = mDisplayName;
@synthesize   authName = mAuthName;
@synthesize   password = mPassword;
@synthesize   userDomain = mUserDomain;
@synthesize   SIPServer = mSIPServer;
@synthesize   SIPServerPort = mSIPServerPort;
@synthesize   transportType = mTransportType;
@synthesize   outboundServer = mOutboundServer;
@synthesize   outboundServerPort = mOutboundServerPort;
@synthesize   enableSTUN = enableSTUN;
@synthesize   STUNServer = STUNServer;
@synthesize   STUNPort = STUNPort;
@synthesize   voiceMail = voiceMail;
@synthesize   presenceAgent = presenceAgent;
@synthesize   publishRefresh = publishRefresh;
@synthesize   subscribeRefresh = subscribeRefresh;
@synthesize   useCert = useCert;
@synthesize   actived = mActived;

-(id) initWithName:(int)accountId
          UserName:(NSString*)userName
       DisplayName:(NSString*)displayName
          AuthName:(NSString*)authName
          Password:(NSString*)password
        UserDomain:(NSString *)userDomain
         SIPServer:(NSString*)SIPServer
     SIPServerPort:(int)SIPServerPort
     TransportType:(NSString*)TransportType
    OutboundServer:(NSString*)outboundServer
OutboundServerPort:(int)outboundServerPort
           Actived:(int)actived
{
    self = [super init];
    if (self)
    {
        mAccountId = accountId;
        mUserName = userName;
        mDisplayName = displayName;
        mAuthName = authName;
        mPassword = password;
        mUserDomain = userDomain;
        mSIPServer = SIPServer;
        mSIPServerPort = SIPServerPort;
        mTransportType = TransportType;
        mOutboundServer = outboundServer;
        mOutboundServerPort = outboundServerPort;
        mActived = actived;
    }
    return self;
}

-(NSString*)getLocalUri{
    if([mUserName rangeOfString:@"@"].location ==NSNotFound){
        if(mUserDomain.length>0){
            return [NSString stringWithFormat:@"%@@%@",mUserName,mUserDomain];
        }else{
            return [NSString stringWithFormat:@"%@@%@",mUserName,mSIPServer];
        }
        
    }
    
    return mUserName;
}

- (NSString*)accountName
{
    return StringNotNull(mDisplayName) ? mDisplayName : mUserName;
}

-(void) dealloc
{
    mUserName = nil;
    mDisplayName = nil;
    mAuthName = nil;
    mPassword = nil;
    mUserDomain = nil;
    mSIPServer = nil;
    mOutboundServer = nil;
}
@end
