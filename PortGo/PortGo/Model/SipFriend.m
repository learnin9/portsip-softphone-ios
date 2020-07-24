//
//  SipFriend.m
//  PortGo
//
//  Created by 今言网络 on 2017/9/7.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "SipFriend.h"

@implementation SipFriend

-(id)initWithIdentifi:(NSString *)identifi SunbscribeID:(long)subscribeid DisplayName:(NSString *)displayName Firstname:(NSString *)firstName Lastname:(NSString *)lastName Company:(NSString *)company Department:(NSString *)department Jobtitle:(NSString *)jobtitle IMNumber:(NSString *)imNumber Comfrom:(int)comefrom DeletFlag:(int)deleteFlag ApplyState:(PS_ApplyState)applyState PhoneNumbers:(NSString *)phoneNumbers IPNumbers:(NSString *)ipNumbers{
    if (self = [super init]) {
        _sipIdentifier = identifi;
        _subscribeID = subscribeid;
        _displayName = displayName;
        _firstName = firstName;
        _lastName = lastName;
        _company = company;
        _partment = department;
        _jobtitle = jobtitle;
        _imNumber = imNumber;
        _comeFrom = comefrom;
        _deleteFlag = deleteFlag;
        _applyState = applyState;
        _phoneNumbers = phoneNumbers;
        _ipCallNumbers = ipNumbers;
    }
    return self;
}

@end
