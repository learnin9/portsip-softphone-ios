//
//  ContactCell.m
//  PortGo
//
//  Created by 今言网络 on 2017/5/19.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "ContactCell.h"
#import "UIColor_Hex.h"

@implementation ContactCell
@synthesize cellSeperatorView;

//-(UIView *)cellSeperatorView{
//    if (!cellSeperatorView) {
//        self.cellSeperatorView = [[UIView alloc] initWithFrame:CGRectZero];
//        [self.cellSeperatorView setBackgroundColor:[UIColor lightGrayColor]];
//        [self.contentView addSubview:self.cellSeperatorView];
//    }
//    return cellSeperatorView;
//}

//-(void)prepareForReuse{
//    [super prepareForReuse];
//    self.cellSeperatorView = nil;
//}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.cellSeperatorView setFrame:CGRectMake(cellSeperatorView.frame.origin.x, cellSeperatorView.frame.origin.y, self.frame.size.width, 0.5)];
    [self traitCollectionDidChange:self.traitCollection];
    
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColorLight"];
    }
    else{
        bkColor = [UIColor lightGrayColor];
    }
    
    cellSeperatorView.backgroundColor = bkColor;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contactIcon.layer.cornerRadius = self.contactIcon.bounds.size.width / 2;
    self.contactIcon.clipsToBounds = YES;
    
    cellSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(10, 59.5, self.bounds.size.width, 0.5)];
    [self.contentView addSubview:cellSeperatorView];
    
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing) {
        for (UIControl *control in self.subviews) {
            if (![control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
                continue;
            }
            
            for (UIView *subView in control.subviews) {
                if (![subView isKindOfClass: [UIImageView class]]) {
                    continue;
                }
                
                UIImageView *imageView = (UIImageView *)subView;
                if (self.selected) {
                    imageView.image = [UIImage imageNamed:@"checkbox_sel"]; // 选中时的图片
                } else {
                    imageView.image = [UIImage imageNamed:@"checkbox_pre"];   // 未选中时的图片
                }
            }
        }

    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (!self.isEditing) {
        return ;
    }
    
    for (UIControl *control in self.subviews) {
        if (![control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            continue;
        }
            
        for (UIView *subView in control.subviews) {
            if (![subView isKindOfClass: [UIImageView class]]) {
                continue;
        }
            
            UIImageView *imageView = (UIImageView *)subView;
            if (selected) {
                imageView.image = [UIImage imageNamed:@"checkbox_sel"]; // 选中时的图片
            } else {
                imageView.image = [UIImage imageNamed:@"checkbox_pre"];   // 未选中时的图片
            }
        }
    }
    
    // Configure the view for the selected state
}

@end
