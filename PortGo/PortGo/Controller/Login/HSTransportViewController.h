//
//  HSTransportViewController.h
//  PortGo
//
//  Created by MrLee on 14-9-30.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HSTransportViewControllerDelegate <NSObject>
- (void)didSelectTranport:(NSString *)tranport;
@end

@interface HSTransportViewController : UIViewController
@property (nonatomic, copy) NSString *lastSelectTranport;
@property (nonatomic, weak) id<HSTransportViewControllerDelegate> delegate;
@end
