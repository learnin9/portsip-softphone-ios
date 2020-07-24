//
//  PortSipSignalHandler.m
//  PortGo
//
//  Created by 今言网络 on 2017/10/18.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "PortSipSignalHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>


volatile int32_t UncaughtExceptionCount = 0;
volatile int32_t UncaughtExceptionMaximum = 10;


void callbackHandlerOfCatchedSignal(int signo)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    NSMutableDictionary *userInfo =[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signo] forKey:@"signal"];
    NSException *ex = [NSException exceptionWithName:@"SignalExceptionName" reason:[NSString stringWithFormat:@"Signal %d was raised.\n",signo] userInfo:userInfo];
    [[PortSipSignalHandler instance] performSelectorOnMainThread:@selector(handleExceptionTranslatedFromSignal:) withObject:ex waitUntilDone:YES];
}

@interface PortSipSignalHandler ()

@property BOOL isDissmissed ;

/**
 *
 */
-(void)registerSignalHandler;

@end

@implementation PortSipSignalHandler

/**
 *
 *
 *  @return
 */
+ (instancetype)instance{
    
    static dispatch_once_t onceToken;
    static  PortSipSignalHandler *s_SignalHandler =  nil;
    
    dispatch_once(&onceToken, ^{
        if (s_SignalHandler == nil) {
            s_SignalHandler  =  [[PortSipSignalHandler alloc] init];
            [s_SignalHandler registerSignalHandler];
        }
    });
    return s_SignalHandler;
}

/**
 *
 */
- (void)registerSignalHandler
{
    signal(SIGABRT, callbackHandlerOfCatchedSignal);
    signal(SIGILL, callbackHandlerOfCatchedSignal);
    signal(SIGSEGV, callbackHandlerOfCatchedSignal);
    signal(SIGFPE, callbackHandlerOfCatchedSignal);
    signal(SIGBUS, callbackHandlerOfCatchedSignal);
    signal(SIGPIPE, callbackHandlerOfCatchedSignal);
}


- (void)handleExceptionTranslatedFromSignal:(NSException *)exception
{
}
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    _isDissmissed = YES;
}


@end
