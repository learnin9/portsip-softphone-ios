//
//  UINavigationController+InterfaceOrientation.m
//  PortGo
//
//  Created by 今言网络 on 2017/7/5.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "UINavigationController+InterfaceOrientation.h"

@implementation UINavigationController (InterfaceOrientation)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
//    return toInterfaceOrientation != UIDeviceOrientationPortraitUpsideDown;
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}

@end
