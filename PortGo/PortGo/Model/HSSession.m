//
//  HSSession.m
//  PortGo
//
//  Created by MrLee on 14-10-12.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSSession.h"
#import "AppDelegate.h"
#import "HSCallViewController.h"

@implementation HSSession



- (id)initWithSessionIdAndUUID:(long)sessionId callUUID:(NSUUID*)uuid
                      remoteParty:(NSString*)remoteParty
                      displayName:(NSString*)displayName
                       videoState:(BOOL)video
                          callOut:(BOOL)outState
{
    NSLog(@"call remoteParty =%@",remoteParty);
    
    [[NSUserDefaults standardUserDefaults]setObject:remoteParty forKey:@"CallObject"];
    
    
    if (self = [super init]) {
        _callViewController = [[HSCallViewController alloc] initWithNibName:@"HSCallViewController" bundle:nil];
        _callViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        Contact *contact = [contactView getContactByPhoneNumber:remoteParty];
        NSString *nickName = nil;
        if (contact != nil) {
            nickName = contact.displayName;
        }
        else{
            nickName = displayName;
        }
        [_callViewController createCallWithId:uuid isCallOut:outState byRemoteParty:remoteParty byDisplayName:nickName isVideo:video];
        _sessionId = sessionId;
        if(uuid==nil)
        {
            uuid = [NSUUID UUID];
        }
        _uuid = uuid;
        
        _orignalId = -1;
        _videoCall = video;
        _outgoing = outState;
        _callKitAnswered = FALSE;
    }
    

    return self;
}

@end
