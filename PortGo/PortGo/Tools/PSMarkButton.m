//
//  PSMarkButton.m
//  PortGo
//
//  Created by 今言网络 on 2017/7/18.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "PSMarkButton.h"
extern CGFloat const imageViewWH;
@implementation PSMarkButton

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.imageView.frame.size.width <= 0) return;
    
    CGFloat btnW = self.bounds.size.width;
    CGFloat btnH = self.bounds.size.height;
    
    self.titleLabel.frame = CGRectMake(_margin, self.titleLabel.frame.origin.y, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    
    CGFloat imageX = btnW - self.imageView.frame.size.width -  _margin;
    self.imageView.frame = CGRectMake(imageX, (btnH - imageViewWH) * 0.5, imageViewWH, imageViewWH);
}

- (void)setHighlighted:(BOOL)highlighted {

}

@end
