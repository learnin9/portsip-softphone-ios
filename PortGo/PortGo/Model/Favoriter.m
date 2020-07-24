//
//  Favoriter.m
//  PortGo
//
//  Created by portsip on 16/11/18.
//  Copyright © 2016年 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Favoriter.h"
#import "Contact.h"

@implementation Favorite

-(id) initWithIdentifi:(NSString *)contactIdentifi type:(int)phoneType typedescription:(NSString *)typedescription num:(NSString *)phoneNum dispalyname:(NSString *)name {
    self = [super init];
    if (self)
    {
        _mFavoriteIdentifi = contactIdentifi;
        _mPhoneNum = phoneNum;
        _mDisplayName = name;
        _mPhoneType = phoneType;
        _mTypeDescription = typedescription;
    }
    return self;
}

-(id) initWithID:(int)contactId type:(int)phoneType typedescription:(NSString*)typedescription num:(NSString*)phoneNum dispalyname:(NSString*)name
{
    self = [super init];
    if (self)
    {
        _mFavoriteId = contactId;
        _mPhoneNum = phoneNum;
        _mDisplayName = name;
        _mPhoneType = phoneType;
        _mTypeDescription = typedescription;
    }
    return self;
}

-(void) dealloc
{
}
@end
