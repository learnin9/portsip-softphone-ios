//
//  Favoriter.h
//  PortGo
//
//  Created by portsip on 16/11/18.
//  Copyright © 2016年 PortSIP Solutions, Inc. All rights reserved.
//

@interface Favorite : NSObject;

@property(nonatomic,copy)NSString *mDisplayName;
@property(nonatomic,copy)NSString *mPhoneNum;
@property(nonatomic,copy)NSString *mTypeDescription;
@property(nonatomic,assign)int mFavoriteId;
@property(nonatomic,copy)NSString *mFavoriteIdentifi;
@property(nonatomic,assign)int mPhoneType;

-(id) initWithIdentifi:(NSString *)contactIdentifi type:(int)phoneType typedescription:(NSString*)typedescription num:(NSString*)phoneNum dispalyname:(NSString*)name;

-(id) initWithID:(int)contactId type:(int)phoneType typedescription:(NSString*)typedescription num:(NSString*)phoneNum dispalyname:(NSString*)name;

@end
