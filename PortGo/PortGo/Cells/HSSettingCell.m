//
//  HSSettingCell.m
//  PortGo
//
//  Created by MrLee on 14-9-28.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSSettingCell.h"

@interface HSSettingCell()
@property (weak, nonatomic) IBOutlet UIImageView *settingImage;
@property (weak, nonatomic) IBOutlet UILabel *settingLabel;

@end

@implementation HSSettingCell

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    
    [_settingImage setImage:[UIImage imageNamed:_imageName]];
}

- (void)setLabel:(NSString *)label
{
    _label = label;
    _settingLabel.text = _label;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *seperator in self.subviews) {
        if ([seperator isMemberOfClass:NSClassFromString(@"_UITableViewCellSeparatorView")]) {
            seperator.alpha = 0.4;
        }
    }
}

@end
