//
//  HSChatSession.m
//  PortGo
//
//  Created by PortSip on 2019/12/2.
//  Copyright © 2019 PortSIP Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSChatSession.h"

@implementation HSChatSession

-(NSString*)getDisplayName{
    if(_mRemoteDisname.length>0){
        return _mRemoteDisname;
    }else{
        return self.mRemoteUri;
    }
}
@end

