//
//  GetJson.h
//  PortSIP
//
//  Created by 今言网络 on 2018/5/14.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetJson : NSObject



+(void)getJSON :(NSString*)URL  andDic:(NSDictionary*)dic  complete:(void(^)(id obj))complete;

+(NSString*)convertToJSONData:(id)infoDict;

@end
