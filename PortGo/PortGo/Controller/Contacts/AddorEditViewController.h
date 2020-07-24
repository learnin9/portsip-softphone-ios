//
//  AddorEditViewController.h
//  PortGo
//
//  Created by 今言网络 on 2017/6/7.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

typedef void(^EditContactCompleted)(Contact *returnContact);
typedef void (^AddHistoryToContact)();
typedef void (^EditHistoryToContact)();
typedef void (^AddChatContact)(Contact *chatContact);

@interface AddorEditViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *backGroundScroll;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *firstNamelabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextFeild;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextFeild;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UITextField *companytextFeild;
@property (weak, nonatomic) IBOutlet UILabel *partmentLabel;
@property (weak, nonatomic) IBOutlet UITextField *partmentFeild;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UITextField *jobTextFeild;
@property  UITableView *IPCallTablView;
@property   UITableView *phoneCallTablview;

@property   UITableView *deleteTableview;


@property (nonatomic, strong) EditContactCompleted completBlock;
@property (nonatomic, strong) AddHistoryToContact addCompletBlock;
@property (nonatomic, strong) EditHistoryToContact editCompletBlock;
@property (nonatomic, strong) AddChatContact chatContactBlock;

@property (nonatomic, strong) Contact *aContact;
@property (nonatomic, strong) NSMutableArray *IPCallNumbers;
@property (nonatomic, strong) NSMutableArray *phoneNumbers;

@property (nonatomic, strong) NSString *numbPadenterString;

@property (assign) NSInteger recognizeID ;
@property (assign) NSInteger segmentSelect;

@property NSDictionary * addvoidcall;

@property NSString * addfriendname;

@property BOOL frommessage2;


-(void)didContactEditedCallback:(EditContactCompleted)callback;

-(void)didAddHistoryToContactCallback:(AddHistoryToContact)callback;

-(void)didEditHistoryToContactCallback:(EditHistoryToContact)callback;

-(void)didAddChatContactCallback:(AddChatContact)callback;

@end
