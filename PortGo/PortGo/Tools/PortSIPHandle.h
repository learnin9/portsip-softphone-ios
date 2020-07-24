//
//  PortSIPHandle.h
//  PortGo
//
//  Created by Joe Lepple on 4/26/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//
#import <PortSIPUCSDK/PortSIPUCSDK.h>
#import "Account.h"
#import "Reachability.h"

typedef enum RegistrationStateTypes_e {
	REGISTRATION_NONE,  //Not Register
    REGISTRATION_INPROGRESS, //Registering
    REGISTRATION_OK,    //Registered
    REGISTRATION_FAILE  //Register Failure/has been unregister
}RegistrationStateTypes_t;

@interface PortSIPHandle : PortSIPSDK{
    BOOL    SIPInitialized;
    RegistrationStateTypes_t     registerState;
    Account* mAccount;
    
    Reachability* internetReach;
    NetworkStatus netStatus;
}

@property BOOL SIPInitialized;
@property RegistrationStateTypes_t registerState;
@property (retain, nonatomic) Account* mAccount;

- (BOOL)hasActiveAccount;
- (int)registerToServer:(Account*)account;
- (void) refreshRegister;
- (void) unRegister;
- (void) loginOut;

- (NSString*)getAccountSIPUri;

- (void)onRegisterSuccess:(int)statusCode withStatusText:(char*) statusText;
- (void)onRegisterFailure:(int)statusCode withStatusText:(char*) statusText;
@end
