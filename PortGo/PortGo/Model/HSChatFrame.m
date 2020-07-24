//
//  HSChatFrame.m
//  PortGo
//
//  Created by MrLee on 14-10-8.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSChatFrame.h"
#import "HSChatMessage.h"

@implementation HSChatFrame

- (void)setMessage:(HSChatMessage *)message
{
    _message = message;
    UIFont *lSysFont = [UIFont systemFontOfSize:17.0f];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    CGFloat bgX = 15;
    CGFloat bgY = 30;
    _bgRect = (CGRect){bgX, bgY, screenRect.size.width - 2 * bgX, 0};
    
    
    CGFloat arrowX = 0;
    // CGFloat arrowY = 0;
    CGSize arrowSize = (CGSize){30, 30};
    if (IS_EVENT_INCOMING(_message.status)){
        arrowX = bgX * 2;
    }
    else{
        arrowX = CGRectGetMaxX(_bgRect) - arrowSize.width - 12;
    }
    //    _arrowRect = (CGRect){arrowX, arrowY, arrowSize};
    
    CGFloat nicknameX = bgX;
    CGFloat nicknameY = bgY / 4;
    //CGSize nicknameSize = [_message.nickName sizeWithFont:_sysFont ? _sysFont : lSysFont];
    NSDictionary *fontWithAttributes = @{NSFontAttributeName:_sysFont ? _sysFont : lSysFont};
    
    CGSize nicknameSize = [_message.nickName  sizeWithAttributes:fontWithAttributes];
    _nicknameRect = (CGRect){nicknameX, nicknameY, nicknameSize};
    
    //    CGSize sendtimeSize = [_message.sendTime sizeWithFont:[UIFont systemFontOfSize:15.0f]];
    CGSize sendtimeSize = [_message.sendTime sizeWithAttributes:fontWithAttributes];
    CGFloat sendtimeX = _bgRect.size.width - sendtimeSize.width - bgX;
    CGFloat sendtimeY = nicknameY;
    _sendtimeRect = (CGRect){sendtimeX, sendtimeY, sendtimeSize};
    
    CGFloat msgbodyX = nicknameX;
    CGFloat msgbodyY = CGRectGetMaxY(_nicknameRect);
    CGSize constrainSize = (CGSize){_bgRect.size.width - bgX * 2, MAXFLOAT};
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize msgbodySize = [_message.msgBody sizeWithFont:_sysFont ? _sysFont : lSysFont constrainedToSize:constrainSize lineBreakMode:NSLineBreakByWordWrapping];
    
#pragma clang diagnostic pop
    _msgbodyRect = (CGRect){msgbodyX, msgbodyY, constrainSize.width, msgbodySize.height + nicknameY};
    
    _bgRect.size.height = _msgbodyRect.origin.y + _msgbodyRect.size.height;
}
@end
