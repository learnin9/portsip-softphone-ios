//
//  HSChatSession.h
//  PortGo
//
//  Created by PortSip on 2019/12/2.
//  Copyright © 2019 PortSIP Solutions, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

@interface HSChatSession : NSObject

@property (nonatomic, assign) int mRowid;
@property (nonatomic, assign) int mCount;
@property (nonatomic, assign) int mRemoteid;
@property (nonatomic, assign) int mDelete;
@property (nonatomic, copy) NSString *mContactid;
@property (nonatomic, assign) long mLastTimeConnect;
@property (nonatomic, copy) NSString *mRemoteUri,*mLocalUri,*mStatus;
@property (nonatomic, copy,getter=getDisplayName) NSString *mRemoteDisname;
@end


