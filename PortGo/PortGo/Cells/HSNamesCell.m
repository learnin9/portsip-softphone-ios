//
//  HSNamesCell.m
//  PortGo
//
//  Created by MrLee on 14-9-25.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSNamesCell.h"
@interface HSNamesCell()<UITextFieldDelegate>

@end
@implementation HSNamesCell

- (void)awakeFromNib {
    // Initialization code
    _inputTextField.delegate = self;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChange:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.delegate endEditingWithText:textField.text cell:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
