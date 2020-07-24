//
//  HSChatMessage.h
//  PortGo
//
//  Created by MrLee on 14-10-8.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "History.h"

#define KEY_MIMETYPE @"mimetype"
#define KEY_MESSAGE_READ @"msgRead"

extern bool UrlTest;
@interface HSChatMessage : NSObject

@property (nonatomic, assign) int historyId;
@property (nonatomic, assign) int status;
@property (nonatomic, assign) int msglen;//audio duration
@property (nonatomic, copy) NSString *mimetype;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *sendTime;
@property (nonatomic, copy) NSString *msgBody;
@property (nonatomic, assign) Boolean msgRead;
@property (nonatomic, strong) NSDictionary *jsonContent;
@property BOOL isFirstRow;
@property (nonatomic, assign)CGRect contentRect;
- (id)initWithDict:(NSDictionary*)dict;
-(UIImage*)getImage;
@end
