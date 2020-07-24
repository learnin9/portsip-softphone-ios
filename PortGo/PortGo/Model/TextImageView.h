//
//  TextImageView.h
//  PortGo
//
//  Created by 今言网络 on 2017/7/12.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextImageView : UIView
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) UILabel *textImageLabel;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (assign) CGFloat raduis;
@end
