//
//  HSPreferencesDetailViewController.h
//  PortGo
//
//  Created by MrLee on 14-10-10.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HSPreferencesDetailViewControllerDelegate <NSObject>

- (void)didSelectedRowWithString:(int)selectedRow rowIndexPath:(NSIndexPath *)indexPath;

@end

@interface HSPreferencesDetailViewController : UITableViewController

@property (nonatomic, retain) NSArray *cellDataArray;
@property (nonatomic, weak) id<HSPreferencesDetailViewControllerDelegate> delegate;

- (instancetype)initWithArray:(NSArray *)array defaultSelected:(NSString*)selectedStr title:(NSString*)titleStr rowIndexPath:(NSIndexPath *)indexPath;
@end
