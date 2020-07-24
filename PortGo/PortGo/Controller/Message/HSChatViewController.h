//
//  HSChatViewController.h
//  PortGo
//
//  Created by MrLee on 14-10-7.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"
#import "HSChatSession.h"


@class Contact;

@interface HSChatViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *remoteName;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UILabel *remoteStatus;
@property (weak, nonatomic) IBOutlet UILabel *placehoder;
@property (nonatomic, retain ,setter=setChatSession:)HSChatSession* chatSession;
@property (assign) NSInteger playID;

@property (weak, nonatomic) IBOutlet UILabel *statusImageview;

@property   NSString *tempstr;
@property BOOL  ifonline;


- (BOOL)checkRemoteParty:(NSString *)checkParty;
- (void) refreshDataAndReload;
- (void)hideTableViewHeaderView;
- (void)showTableViewHeaderView;

-(void)setstaimage :(BOOL)online;

@end
