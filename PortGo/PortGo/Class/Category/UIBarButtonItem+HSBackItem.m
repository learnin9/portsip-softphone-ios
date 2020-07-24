//
//  UIBarButtonItem+HSBackItem.m
//  PortGo
//
//  Created by MrLee on 14/10/24.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "UIBarButtonItem+HSBackItem.h"

@implementation UIBarButtonItem (HSBackItem)
+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"login_advanced_nav_back_btn"] forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}
@end
