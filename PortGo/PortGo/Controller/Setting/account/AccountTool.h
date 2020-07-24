//
//  AccountTool.h
//  PortGo
//
//  Created by 今言网络 on 2017/11/13.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountTool : NSObject

@property   NSString *  callforwardindex;
@property  NSString * callforwardtime;
@property  NSString *  callforwardobject;

+(instancetype)initTool;

@end
