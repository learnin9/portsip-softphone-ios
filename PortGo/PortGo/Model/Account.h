//
//  Account.h
//  PortGo
//
//  Created by Joe Lepple on 3/26/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constatnts.h"

@interface Account : NSObject{
@private
    int         mAccountId;
    NSString    *mUserName;
    NSString    *mDisplayName;
    NSString    *mAuthName;
    NSString    *mPassword;
    NSString    *mUserDomain;
    NSString    *mSIPServer;
    int         mSIPServerPort;
    NSString    *mTransportType;
    
    NSString    *mOutboundServer;
    int         mOutboundServerPort;
    
    int         enableSTUN;
    NSString    *STUNServer;
    int         STUNPort;
    
   // NSString    *voiceMail;
    
  
    
    
    int         presenceAgent;
    int         publishRefresh;
    int         subscribeRefresh;
    
    int         useCert;
    
    int         mActived;
}

@property int accountId;
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *displayName;
@property (nonatomic,retain) NSString *authName;
@property (nonatomic,retain) NSString *password;
@property (nonatomic,retain) NSString *userDomain;
@property (nonatomic,retain) NSString *SIPServer;
@property (readonly,nonatomic,retain, getter=getLocalUri) NSString *LocalUri;
@property int SIPServerPort;

@property BOOL  hasOutProxyServer;//Advance 设置了OutPorxy Server

@property (nonatomic,retain) NSString *transportType;
@property (nonatomic,retain) NSString *outboundServer;
@property int outboundServerPort;

@property int enableSTUN;
@property (nonatomic,retain) NSString *STUNServer;
@property int STUNPort;

@property (nonatomic,retain) NSString *voiceMail;

@property (nonatomic,retain) NSData * usericondata;


@property int presenceAgent;
@property int publishRefresh;
@property int subscribeRefresh;

@property int useCert;

@property int actived;

@property (nonatomic, assign) BOOL isOpenlog;

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
           Actived:(int)actived;

- (NSString*)accountName;
@end
