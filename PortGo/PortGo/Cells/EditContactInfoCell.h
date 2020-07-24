//
//  EditContactInfoCell.h
//  PortGo
//
//  Created by 今言网络 on 2017/5/31.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^DelOrAddButtonDidClicked)();

@interface EditContactInfoCell : UITableViewCell
@property (nonatomic, weak) UITextField *infoTextField;
@property (weak, nonatomic) IBOutlet UIButton *delOrAddButton;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;

@property (nonatomic, weak) DelOrAddButtonDidClicked clickCallback;

-(void)didButtonClicked:(DelOrAddButtonDidClicked)callback;

@end
