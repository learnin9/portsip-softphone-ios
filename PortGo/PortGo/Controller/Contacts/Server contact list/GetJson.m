//
//  GetJson.m
//  PortSIP
//
//  Created by 今言网络 on 2018/5/14.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import "GetJson.h"

@implementation GetJson



+(void)getJSON :(NSString*)URL  andDic:(NSDictionary*)dic  complete:(void(^)(id obj))complete{
    // http://sipiw.com:8899/api/account/credentials/verify
    
    
    NSURL *url = [NSURL URLWithString:URL];
    
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *dataString =[GetJson convertToJSONData:dic];
    NSData *postData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [mRequest setHTTPMethod:@"POST"];
    [mRequest setHTTPBody:postData];
    
    [mRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:mRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if (connectionError) {
            return ;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if (dict) {
            complete(dict);
            
        }
        
    }];
}

+(NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}
@end
