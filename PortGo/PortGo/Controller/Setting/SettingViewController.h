//
//  SettingViewController.h
//  PortGo
//
//  Created by Joe Lepple on 4/19/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UITableViewController{
    NSMutableArray *settingsItems;
    
    BOOL onlinestate;
}


-(void)showonline:(BOOL)online;
@end
