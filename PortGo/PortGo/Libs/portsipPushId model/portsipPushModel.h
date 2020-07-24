//
//  portsipPushModel.h
//  PortSIP
//
//  Created by 今言网络 on 2018/1/10.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface portsipPushModel : NSObject


@property NSString *portsipPushId;

@property NSString * timestamp;


+(NSString*)getCurrentTimestamp;

@end
