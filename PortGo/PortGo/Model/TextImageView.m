//
//  TextImageView.m
//  PortGo
//
//  Created by 今言网络 on 2017/7/12.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "TextImageView.h"
#import "UIColor_Hex.h"

@implementation TextImageView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        
        _textImageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - 10, self.bounds.size.height - 10)];
        _textImageLabel.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _textImageLabel.textAlignment = NSTextAlignmentCenter;
        CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(-15 * (CGFloat)M_PI / 180), 1, 0, 0);
        _textImageLabel.transform = matrix;
        _textImageLabel.textColor = MAIN_COLOR;
        [self addSubview:_textImageLabel];
        [self traitCollectionDidChange:[self traitCollection]];
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bkColor = [UIColor whiteColor];
    }
    
    self.backgroundColor = bkColor;
}


-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor* mainColor = MAIN_COLOR;
    const CGFloat *components = CGColorGetComponents(mainColor.CGColor);
    CGContextSetRGBStrokeColor(context, components[0], components[1],  components[2], 1.0);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddArc(context, self.bounds.size.width / 2, self.bounds.size.height / 2, _raduis, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathStroke);
}

-(void)setString:(NSString *)string {
    _textImageLabel.text = string;
}

@end
