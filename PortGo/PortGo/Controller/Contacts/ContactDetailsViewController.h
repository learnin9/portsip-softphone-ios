//
//  ContactDetailsViewController.h
//  PortGo
//
//  Created by Joe Lepple on 4/10/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "History.h"

typedef void (^ContactDetaildidChangeGroup)();

@interface ContactDetailsViewController : UITableViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    //table header
    UIView *viewHeader;
    UILabel *labelDisplayName;
    
    //table footer
    UIView *viewFooter;
    UIButton *buttonVideoCall;
    UIButton *buttonTextMessage;
    UIButton *buttonAudioCall;
    
    Contact *contact;
    
    int superControllerID;//RecentsView = 1, ContactView = 2 ,ChatView = 3，peopelselect ＝ 4
}

@property(nonatomic,retain) IBOutlet UIView *viewHeader;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewAvatar;

@property (nonatomic,retain) Contact *contact;
@property (nonatomic, strong) History *callHistory;

@property NSString * partystr;


@property (nonatomic, assign) BOOL showCreateOption;

@property (nonatomic, strong) ContactDetaildidChangeGroup callback;

@property (nonatomic, strong) NSMutableArray *historyRecords;

@property int superControllerID;

@property  BOOL  ifFormPhoneCallList;

@property BOOL frommessagebutton;

@property BOOL fromfirendlist;


@property (assign) NSInteger superIndex;

-(void)contactDetailGroupDidChangedCallback:(ContactDetaildidChangeGroup)callback;

@property   void(^imblock)(NSString *imstr);

@end
