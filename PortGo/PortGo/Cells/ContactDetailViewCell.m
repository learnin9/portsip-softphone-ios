//
//  ContactDetailViewCell.m
//  PortGo
//
//  Created by 今言网络 on 2017/5/19.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "ContactDetailViewCell.h"

@implementation ContactDetailViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.audioBtn.layer.cornerRadius = self.audioBtn.bounds.size.width / 2;
    self.videoBtn.layer.cornerRadius = self.videoBtn.bounds.size.width / 2;
    self.messageBtn.layer.cornerRadius = self.messageBtn.bounds.size.width / 2;
}
- (IBAction)buttonClick:(id)sender {
    self.click(sender);
}

-(void)didButtonClickedCallback:(ButtonClick)click {
    self.click = click;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
