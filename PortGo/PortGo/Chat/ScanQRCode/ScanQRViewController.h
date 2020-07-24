//
//  ScanQRViewController.h
//  PortSIP
//
//  Created by 今言网络 on 2018/3/12.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScanDelegateProtocol <NSObject>
- (void)scanFinish:(NSString*)result;
@end

@interface ScanQRViewController : UIViewController
@property (nonatomic, weak) id<ScanDelegateProtocol> scanDelegate;
@end


