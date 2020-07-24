//
//  HSNamesCell.h
//  PortGo
//
//  Created by MrLee on 14-9-25.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HSNamesCell;

@protocol HSNamesCellDelegate <NSObject>

- (void)endEditingWithText:(NSString *)str cell:(HSNamesCell*)cell;

@end

@interface HSNamesCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (nonatomic, weak) id<HSNamesCellDelegate> delegate;
@end
