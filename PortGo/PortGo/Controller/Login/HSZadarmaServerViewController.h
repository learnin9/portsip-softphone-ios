//
//  HSZadarmaServerViewController.h
//  PortGo
//
//  Created by MrLee on 14/10/30.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HSSipServer;
@protocol HSZadarmaServerViewControllerDelegate <NSObject>

- (void)didSelectSIPServer:(HSSipServer *)sipServrer;

@end

@interface HSZadarmaServerViewController : UIViewController
@property (nonatomic, weak) id<HSZadarmaServerViewControllerDelegate> delegate;
@end
