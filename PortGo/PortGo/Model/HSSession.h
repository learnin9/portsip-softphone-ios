//
//  HSSession.h
//  PortGo
//
//  Created by MrLee on 14-10-12.
//  Copyright (c) 2016 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_LINES 2

@class HSCallViewController;
@interface HSSession : NSObject

@property (nonatomic, retain) HSCallViewController *callViewController;
@property (nonatomic, retain) UILocalNotification* notification;
@property (nonatomic, retain) NSUUID* uuid;
@property (nonatomic, retain) NSUUID* groupUUID;
@property (nonatomic, assign) long orignalId;
@property (nonatomic, assign) BOOL sessionState;//Call is connected
@property (nonatomic, assign) BOOL holdState;
@property (nonatomic, assign) BOOL videoCall;
@property (nonatomic, assign) BOOL outgoing;//Yes:outgoing call No:incoming call
@property (nonatomic, assign) long sessionId;
@property (nonatomic, assign) BOOL callKitAnswered;
@property (nonatomic, assign) BOOL callKitReject;
@property (nonatomic, retain) NSTimer *outTimer;
@property(nonatomic, strong) void (^callKitCompletionCallback)(BOOL);

-(id)initWithSessionIdAndUUID:(long)sessionId callUUID:(NSUUID*)uuid
remoteParty:(NSString*)remoteParty
displayName:(NSString*)displayName
videoState:(BOOL)video
callOut:(BOOL)outState;

@end
