//
//  AccountTool.m
//  PortGo
//
//  Created by 今言网络 on 2017/11/13.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "AccountTool.h"

@implementation AccountTool


+(instancetype)initTool{
    
    static AccountTool* tool = nil;
    
    static dispatch_once_t onceToken;
    
    
    dispatch_once(&onceToken,^{
        
        tool = [[self alloc]init];
        
        
    });
    
    return tool;
    
}
@end
