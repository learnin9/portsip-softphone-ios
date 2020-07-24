//
//  PortSipSignalHandler.h
//  PortGo
//
//  Created by 今言网络 on 2017/10/18.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/signal.h>

@interface PortSipSignalHandler : NSObject

+ (instancetype)instance;
- (void)handleExceptionTranslatedFromSignal:(NSException *)exception;

@end
