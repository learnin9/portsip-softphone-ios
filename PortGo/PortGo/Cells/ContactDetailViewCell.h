//
//  ContactDetailViewCell.h
//  PortGo
//
//  Created by 今言网络 on 2017/5/19.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ButtonClick)(id sender);

@interface ContactDetailViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberNType;
@property (weak, nonatomic) IBOutlet UIButton *audioBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (nonatomic, strong) ButtonClick click;

-(void)didButtonClickedCallback:(ButtonClick)click;

@end
