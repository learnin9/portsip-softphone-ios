//
//  HistoryDetailCell.h
//  PortGo
//
//  Created by 今言网络 on 2017/6/16.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"

@interface HistoryDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *callType;
@property (weak, nonatomic) IBOutlet UILabel *callState;

-(void)setHistoryDetailCellwith:(History *)record;

@end
