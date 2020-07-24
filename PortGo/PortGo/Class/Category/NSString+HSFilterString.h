//
//  NSString+HSFilterString.h
//  PortGo
//
//  Created by MrLee on 14/10/24.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HSFilterString)

- (NSString*)stringWithFilterString:(NSString*)string;
- (NSString*)stringWithFilterPhoneNumber:(NSString*)string;
- (NSString*)getUriUsername:(NSString*)uri;
- (NSString*)getTimeStart:(long)time;
@end
