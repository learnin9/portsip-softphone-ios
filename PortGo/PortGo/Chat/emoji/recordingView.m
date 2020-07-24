//
//  recordingView.m
//  PortSIP
//
//  Created by 今言网络 on 2018/4/26.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import "recordingView.h"
#import "UIColor_Hex.h"

@interface recordingView()


@property (strong,nonatomic)UIImageView * imageview;

@property (strong,nonatomic) UILabel* textLabel;

@property (strong,nonatomic) NSArray* animationImages;


@end



@implementation recordingView


-(instancetype)initWithFrame:(CGRect)frame{
    
    
    if (self = [super initWithFrame:frame]) {
        
        [self setBackgroundColor:RGB(118, 118, 118)];

        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:10.0f];
        self.alpha = 0.9;
        
        
        [self addSubview:self.imageview];
        
        [self addSubview:self.textLabel];
        self.animationImages = @[
        [UIImage imageNamed:@"voice_recording1"],
        [UIImage imageNamed:@"voice_recording2"],
        [UIImage imageNamed:@"voice_recording3"],
        [UIImage imageNamed:@"voice_recording4"],
        [UIImage imageNamed:@"voice_recording"]];
        
        
    }
    return  self;
    
    
    
}


-(void)setUI:(NSInteger)index{
    
    if (index==0) {
        
        //显示上滑取消
        self.imageview.animationImages = self.animationImages;
        self.imageview.animationDuration = self.animationImages.count/3;
        [self.imageview startAnimating];
        
        //[self.imageview setImage:[UIImage imageNamed:@"message_send_voic_message_ico"]];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel .text = NSLocalizedString(@"Slide up to cancel", @"Slide up to cancel");
        
        
        
         //   [self.imageview setFrame:CGRectMake((150-90)/2, 20, 70, 90)];
    }else
    {
          //显示松开取消
        [self.imageview stopAnimating];
        [self.imageview setImage:[UIImage imageNamed:@"message_loose_hands_ico"]];
        
    //    [self.imageview setFrame:CGRectMake((150-90)/2, 20, 70, 90)];
        
        
        self.textLabel.backgroundColor =RGB(157, 56, 54);
        
        
        self.textLabel .text = NSLocalizedString(@"Release to cancel", @"Release to cancel");
        
    }
    
    
}


-(void)setFrame:(CGRect)frame{
    
          [super setFrame:frame];
    
            [self.imageview setFrame:CGRectMake((150-90)/2, 25, 70, 80)];
    
    
    
    
     //  [self.imageview setBackgroundColor:[UIColor redColor]];
    
    
        [self.textLabel setFrame:CGRectMake(10, 120,  130, 20)];
    
        //self.textLabel.backgroundColor = [UIColor yellowColor];
    
    
    
}

-(UIImageView*)imageview
{
    
    if (!_imageview) {
        
        _imageview =  [[UIImageView alloc]init];
        
        
        
    }
    
    return _imageview;
    
}


-(UILabel*)textLabel
{
    
    if (!_textLabel) {
        
        _textLabel =  [[UILabel alloc]init];

        _textLabel.font = [UIFont systemFontOfSize:14.f];
        
        _textLabel.textAlignment = NSTextAlignmentCenter;
        
        _textLabel.textColor = [UIColor whiteColor];
        
        
    }
    
    return _textLabel;
    
}




@end
