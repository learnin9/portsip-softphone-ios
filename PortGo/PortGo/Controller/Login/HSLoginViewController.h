//
//  HSLoginViewController.h
//  PortGo
//
//  Created by MrLee on 14-9-22.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLAsyncGet.h"
@class Account;
@interface HSLoginViewController : UIViewController<URLAsyncGetDelegate,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, retain) Account *mAccount;
//- (void)textfieldDidChanged:(UITextField*)textField;
- (void)textFieldDidChanged:(UITextField*)textField;
- (void)setAccount:(Account*)account;
@property (weak, nonatomic) IBOutlet UIView *loginView3;
@end
