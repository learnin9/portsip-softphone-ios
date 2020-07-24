//
//  EditContactInfoCell.m
//  PortGo
//
//  Created by 今言网络 on 2017/5/31.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "EditContactInfoCell.h"

@interface EditContactInfoCell () <UITextFieldDelegate>

@end

@implementation EditContactInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)deleteOrAddAction:(id)sender {
    if (self.clickCallback) {
        self.clickCallback();
    }
}

-(void)didButtonClicked:(DelOrAddButtonDidClicked)callback {
    self.clickCallback = callback;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
