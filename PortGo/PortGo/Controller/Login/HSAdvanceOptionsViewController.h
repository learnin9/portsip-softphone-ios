//
//  HSAdvanceOptionsViewController.h
//  PortGo
//
//  Created by portsip on 17/4/17.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"

@protocol HSAdvanceOptionsViewControllerDelegate <NSObject>
-(void)didSetOptionWith:(Account *)account;
@end

@interface HSAdvanceOptionsViewController : UIViewController
@property (nonatomic, strong) Account* account;
@property (nonatomic, weak) id<HSAdvanceOptionsViewControllerDelegate> delegate;
@property (assign) BOOL isOpenLog;
@property BOOL isViewAdvance2;
@property  NSString * username;

@end
