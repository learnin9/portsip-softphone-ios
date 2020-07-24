//
//  HSNamesViewController.h
//  PortGo
//
//  Created by MrLee on 14-9-25.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Account;
@protocol HSNamesViewControllerDelegate <NSObject>

- (void)didWriteDoneWithDisplayName:(NSString *)displayName AuthorName:(NSString *)authorName Domain:(NSString *)domain;

@end

@interface HSNamesViewController : UIViewController

@property (nonatomic, weak) id<HSNamesViewControllerDelegate> delegate;
@property (nonatomic, retain) Account *account;

@end
