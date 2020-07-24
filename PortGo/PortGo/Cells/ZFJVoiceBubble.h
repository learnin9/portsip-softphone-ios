//
//  ZFJVoiceBubble.h
//  打分界面
//
//  Created by ZFJ on 2017/3/8.
//  Copyright © 2017年 ZFJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFJVoiceBubble;

@protocol ZFJVoiceBubbleDelegate <NSObject>

- (void)voiceBubbleDidStartPlaying:(ZFJVoiceBubble *)voiceBubble;

- (void)voiceBubbleStratOrStop:(BOOL)isStart;

@end

@interface ZFJVoiceBubble : UIView

@property (strong, nonatomic) NSURL *contentURL;
@property (assign, nonatomic) BOOL  invert;
@property (assign, nonatomic) BOOL  isHaveBar;
@property (assign, nonatomic) BOOL  isShowLeftImg;
@property (assign, nonatomic) id<ZFJVoiceBubbleDelegate> delegate;
@property (strong, nonatomic) NSString *userName;

- (void)play;
- (void)pause;
- (void)stop;

- (void)startAnimating;
- (void)stopAnimating;

@end
