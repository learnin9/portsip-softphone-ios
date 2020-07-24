//
//  NSString+HSFilterString.m
//  PortGo
//
//  Created by MrLee on 14/10/24.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "NSString+HSFilterString.h"
#define RegexStr @"[0-9a-zA-Z.@]$"
#define PhoneNumRegexStr @"[0-9-+\\(\\)\\s]+$"
#define ValidatePhoneNumRegexStr @"[0-9+]$"

@implementation NSString (HSFilterString)
- (NSString*)stringWithFilterString:(NSString *)string
{
    NSRange range;
    range.location = 0;
    range.length = 1;
    NSString *result = @"";
    for (int i = 0; i < [string length]; ++i)
    {
        range.location = i;
        NSString *temp = [string substringWithRange:range];
        if ([temp rangeOfString:RegexStr options:NSRegularExpressionSearch].location != NSNotFound) {
            result = [result stringByAppendingString:temp];
        }
    }
    if ([result isEqualToString:@""]) {
        return string;
    }
    return result;
}

- (NSString*)stringWithFilterPhoneNumber:(NSString*)string
{
    NSRange range;
    range.location = 0;
    range.length = 1;
    NSString *result = @"";
    
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PhoneNumRegexStr];
    BOOL isMatch = [pred evaluateWithObject:string];
    if (isMatch) {
        for (int i = 0; i < [string length]; ++i)
        {
            range.location = i;
            NSString *temp = [string substringWithRange:range];
            if ([temp rangeOfString:ValidatePhoneNumRegexStr options:NSRegularExpressionSearch].location != NSNotFound) {
                result = [result stringByAppendingString:temp];
            }
        }
    }
    if ([result isEqualToString:@""]) {
        return string;
    }
    return result;
}


- (NSString*)getUriUsername:(NSString*)uri
{
    // SIP-URI = sip:x@y:Port  where x=Username and y=host (domain or IP)
    NSString* userName;
    NSArray *domainArray=[uri componentsSeparatedByString:@"@"];
    //sip:x@y:Port if have Domain,remove it
    userName = domainArray[0];
    
    //sip:x if have sip:remove it
    NSArray *userArray=[userName componentsSeparatedByString:@":"];
    //sip:x@y:Port if have Domain,remove it
    if([userArray count]==2)
        return userArray[1];
    else
        return userArray[0];
}

-(NSString*)getTimeStart:(long)time
{
    NSDate *start = [NSDate dateWithTimeIntervalSince1970:time];
    NSTimeInterval timeStart = time;
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    //NSDate *dateNow = [[NSDate alloc] init];
    
    NSTimeInterval timeToday = timeNow - ((long)timeNow % 86400);
    NSTimeInterval timeThisWeek = timeNow - ((long)timeNow % 86400) - (86400 * 6);
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    if(timeStart > timeToday)
    {
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    }
    else if(timeStart > timeThisWeek)
    {
        [dateFormatter setDateFormat:@"EEEE"];
    }
    else
    {
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    return [dateFormatter stringFromDate:start];
    //return [mHistoryEventDate stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self mTimeStart]]];
}
@end
