//
//  portsipPushModel.m
//  PortSIP
//
//  Created by 今言网络 on 2018/1/10.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import "portsipPushModel.h"

@implementation portsipPushModel




+(NSString*)getCurrentTimestamp{
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[dat timeIntervalSince1970];
        NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
        return timeString;
    }
    


@end
