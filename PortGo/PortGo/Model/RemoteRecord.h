//
//  RemoteRecord.h
//  PortGo
//
//  Created by PortSip on 2019/12/4.
//  Copyright © 2019 PortSIP Solutions, Inc. All rights reserved.
//

#ifndef RemoteRecord_h
#define RemoteRecord_h
@interface RemoteRecord :NSObject

@property (nonatomic, assign) int mRowId;

@property (nonatomic, copy)NSString * mContactId;
@property (nonatomic, assign) int mContactType;

@property (nonatomic, copy)NSString *mRemoteUri;
@property (nonatomic, copy)NSString *mRemoteDisName;
@end
#endif /* RemoteRecord_h */
