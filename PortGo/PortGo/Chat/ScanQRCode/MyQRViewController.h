//
//  MyQRViewController.h
//  PortSIP
//
//  Created by 今言网络 on 2018/3/12.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyQRViewController : UIViewController


@property NSString * titlestr;


@property (nonatomic, strong) UIImage * qrImage;

@property (nonatomic, copy) NSString * qrString;

@property BOOL pushBool;

@end
