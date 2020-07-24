//
//  ContactCell.h
//  PortGo
//
//  Created by 今言网络 on 2017/5/19.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *contactIcon;
@property (weak, nonatomic) IBOutlet UILabel *contactDisplayName;
@property (nonatomic, strong) UIView *cellSeperatorView;
@end
