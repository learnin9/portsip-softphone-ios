//
//  LineStateViewController.h
//  PortGo
//
//  Created by 今言网络 on 2017/6/13.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SelectStateCallback)(NSDictionary *state);

@interface LineStateViewController : UIViewController
@property SelectStateCallback callback;

@property (nonatomic, strong) NSString *stateString;

-(void)didSelectlineStateCallback:(SelectStateCallback)callback;

@end
