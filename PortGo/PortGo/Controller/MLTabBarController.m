//
//  MLTabBarController.m
//  PortGo
//
//  Created by MrLee on 14/12/12.
//  Copyright (c) 2014 PortSIP Solutions, Inc. All rights reserved.
//

#import "MLTabBarController.h"
@implementation MLTabBarController

//#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
- (BOOL)shouldAutorotate
{
//    if([[self selectedViewController] isKindOfClass:[NumpadViewController class]]){
//        return YES;
//    }
    return [super shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [super preferredInterfaceOrientationForPresentation];
}
//#endif
@end
