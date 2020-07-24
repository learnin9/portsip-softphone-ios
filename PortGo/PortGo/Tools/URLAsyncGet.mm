//
//  URLAsyncGet.m
//
//  Created by Joe Lepple on 4/12/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. . All rights reserved.
//

#import "URLAsyncGet.h"
#import "PortMD5.hxx"

#include <string.h>
#include "GlobalSetting.h"

@interface URLAsyncGet(){
    NSMutableData *receivedData;
    id<URLAsyncGetDelegate> mDelegate;
    
    int mRequestUrlType;//0 sendRequestByGet 1- getBalance


#ifdef ENABLE_AUTO_PROVISIONING
    Account* autoProvisioningAccount;
#endif
}

@end

@implementation URLAsyncGet

-(void) getBalance:(NSString*)username password:(NSString*)password  delegate:(id)delegate
{
    NSString *balanceUrl = nil;
    if(balanceUrl)
    {
        mRequestUrlType = 1;
        [self sendRequestByGet:balanceUrl delegate:delegate];
    }
}

-(void) getCreditTime:(NSString*)username password:(NSString*)password callto:(NSString*)callto  delegate:(id)delegate
{
    NSString *creditTimeUrl = nil;
    if(creditTimeUrl)
    {
        mRequestUrlType = 2;
        [self sendRequestByGet:creditTimeUrl delegate:delegate];
    }
}

- (void)sendRequestByGet:(NSString*)urlString  delegate:(id)delegate
{
    NSURL *url=[NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:60];

    [request setHTTPMethod:@"GET"];
    [request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    //receivedData=[[NSMutableData alloc] initWithData:nil];
    receivedData = [NSMutableData data];
    if(mRequestUrlType != 3)
    {
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: NO];
        [connection start];
        //[[NSURLConnection alloc] initWithRequest:request delegate:self];
        //[NSURLConnection connectionWithRequest:request delegate:self];
    }
    mDelegate = delegate;
    
};


-(void) getAutoProvisioning:(Account*)account delegate:(id)delegate
{
#ifdef ENABLE_AUTO_PROVISIONING
    autoProvisioningAccount = account;
#endif//ENABLE_AUTO_PROVISIONING
}
- (void)connection:(NSURLConnection *)aConn didReceiveResponse:(NSURLResponse *)response {
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
    }
}

- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error{
    NSLog(@"connection load Fail");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn {
    
    NSString *strRet = [[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
    
    if(mRequestUrlType == 1)
    {//getBalance
        [mDelegate ReceiveBalance:strRet];
    }
    else if(mRequestUrlType == 2)
    {//getCreditTime
        
    }
    else if(mRequestUrlType == 3)
    {//getSetting

    }
    else
    {
        [mDelegate ReceiveDataFinish:strRet];
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

@end
