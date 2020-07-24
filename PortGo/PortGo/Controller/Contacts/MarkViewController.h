//
//  MarkViewController.h
//  PortGo
//
//  Created by 今言网络 on 2017/6/8.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^DidmarkSlected)(NSString *mark);

@interface MarkViewController : UIViewController
@property (nonatomic, strong) NSMutableDictionary *info;
@property (nonatomic, strong) DidmarkSlected callBack;

-(void)didMarkSelectedCallBack:(DidmarkSlected)callback;

@end
