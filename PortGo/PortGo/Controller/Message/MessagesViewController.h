//
//  MessagesViewController.h
//  PortGo
//
//  Created by Joe Lepple on 4/13/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"
#import "HSChatViewController.h"
#import "Account.h"
@interface MessagesViewController : UITableViewController{
    UIBarButtonItem *navigationItemEdit;
    UIBarButtonItem *navigationItemDone;
    UIBarButtonItem *navigationItemCompose;
    UIBarButtonItem *navigationItemSelectAll;    
    //NSMutableArray* messages;
    NSMutableArray * selectSessions;
    NSMutableArray* chatSessions;
    
    Account *mAccount;
}

@property(nonatomic, assign) MediaType_t mMessageFilter;

- (IBAction) onButtonNavivationItemClick: (id)sender;
- (IBAction) onButtonComposeClick: (id)sender;

- (void)onRecvOutOfDialogMessage:(long)messageId
                 fromDisplayName:(NSString*)fromDisplayName
                            from:(NSString*)from
                        mimeType:(NSString*)mimeType
                     subMimeType:(NSString*)subMimeType
                     messageData:(NSString*)messageData
                     messageTime:(long)messageTime;


- (void)onSendOutOfDialogMessageSuccess:(long)messageId
                        fromDisplayName:(char*)fromDisplayName
                                   from:(char*)from
                          toDisplayName:(char*)toDisplayName
                                     to:(char*)to;

- (void)onSendOutOfDialogMessageFailure:(long)messageId
                        fromDisplayName:(char*)fromDisplayName
                                   from:(char*)from
                          toDisplayName:(char*)toDisplayName
                                     to:(char*)to
                                 reason:(char*)reason
                                   code:(int)code;

//- (void)testAddHistoryData;

- (void)onPresenceRecvSubscribe:(long)subscribeId
                fromDisplayName:(NSString*)fromDisplayName
                           from:(NSString*)from
                        subject:(NSString*)subject;

//- (void)cleanBadges;

-(void)loginoutEmptyHistory;


@end
