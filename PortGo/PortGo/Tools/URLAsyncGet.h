//
//  URLAsyncGet.h
//  Created by Joe Lepple on 4/12/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLSettingParser.h"
#import "Account.h"

@protocol URLAsyncGetDelegate <NSObject>
@optional
-(void)ReceiveDataFinish:(NSString*)srtData;
-(void)ReceiveBalance:(NSString*)balanceValue;
-(void)ReceiveCreditTime:(NSString*)numberType CreditTime:(NSString*)creditTimeValue;
//Auto provisioning return sip account
-(void)ReceiveSIPAccount:(BOOL)status;
@end

@interface URLAsyncGet : NSObject


-(void) getBalance:(NSString*)username password:(NSString*)password delegate:(id)delegate;

-(void) getCreditTime:(NSString*)username password:(NSString*)password callto:(NSString*)callto  delegate:(id)delegate;
- (void)sendRequestByGet:(NSString*)urlString delegate:(id)delegate;

-(void) getAutoProvisioning:(Account*)account delegate:(id)delegate;

@end
