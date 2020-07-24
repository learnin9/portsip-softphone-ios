//
//  SipFriend.h
//  PortGo
//
//  Created by 今言网络 on 2017/9/7.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, PS_ApplyState) {
    PS_ApplyStateNone,
    PS_ApplyStateProcessing,
    PS_ApplyStateSuccess,
    PS_ApplyStateRejected
};

@interface SipFriend : NSObject
@property int ID;
@property long subscribeID;
@property long outSubscribeId;
@property(nonatomic, strong) NSString *sipIdentifier;
@property(nonatomic, strong) NSString* displayName;
@property(nonatomic, strong) NSString* firstName;
@property(nonatomic, strong) NSString* lastName;
@property(nonatomic, strong) NSString* company;
@property(nonatomic, strong) NSString* partment;
@property(nonatomic, strong) NSString* jobtitle;
@property(nonatomic, strong) NSString* phoneNumbers;
@property(nonatomic, strong) NSString* ipCallNumbers;
@property(nonatomic, strong) NSData* picture;
@property(nonatomic, strong) NSDate* creatDate;
@property(nonatomic, strong) NSString *imNumber; //IMNumber

@property int comeFrom;
@property int deleteFlag;
@property (nonatomic, assign) PS_ApplyState applyState;

-(id)initWithIdentifi:(NSString *)identifi SunbscribeID:(long)subscribeid DisplayName:(NSString *)displayName Firstname:(NSString *)firstName Lastname:(NSString *)lastName Company:(NSString *)company Department:(NSString *)department Jobtitle:(NSString *)jobtitle IMNumber:(NSString *)imNumber Comfrom:(int)comefrom DeletFlag:(int)deleteFlag ApplyState:(PS_ApplyState)applyState PhoneNumbers:(NSString *)phoneNumbers IPNumbers:(NSString *)ipNumbers;

@end
