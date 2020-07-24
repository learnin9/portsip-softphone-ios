//
//  HSChatFrame.h
//  PortGo
//
//  Created by MrLee on 14-10-8.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HSChatMessage;

@interface HSChatFrame : NSObject

@property (nonatomic, retain) HSChatMessage *message;

@property (nonatomic, retain) UIFont *sysFont;

@property (nonatomic, assign) CGRect arrowRect;
@property (nonatomic, assign) CGRect bgRect;
@property (nonatomic, assign) CGRect nicknameRect;
@property (nonatomic, assign) CGRect sendtimeRect;
@property (nonatomic, assign) CGRect msgbodyRect;
@end
