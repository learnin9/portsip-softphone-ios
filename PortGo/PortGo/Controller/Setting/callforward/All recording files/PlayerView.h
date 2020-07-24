//
//  PlayerView.h
//  iOSPlayerStudy
//
//  Created by 今言网络 on 2017/11/17.
//  Copyright © 2017年 付航. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerView : UIView 


+ (instancetype)PlayerViewWithFrame:(CGRect)frame;

-(void)play :(NSURL*)url ;


@property(nonatomic,copy) void(^headviewBlock)();


@end
