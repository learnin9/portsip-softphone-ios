//
//  IMEditViewController.h
//  PortGo
//
//  Created by 今言网络 on 2017/9/11.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^IMSaveBlock)(NSString *imnuber);

@interface IMEditViewController : UIViewController
@property (nonatomic, strong) NSString *contacrIM;
@property (nonatomic, strong) NSMutableArray *IMAddresses;
@property (nonatomic, strong) IMSaveBlock block;

-(void)didIMAddressSaved:(IMSaveBlock)callback;

@end
