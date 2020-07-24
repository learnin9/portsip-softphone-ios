//
//  PlayerView.m
//  iOSPlayerStudy
//
//  Created by 今言网络 on 2017/11/17.
//  Copyright © 2017年 付航. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>
#define heightt 150



@interface PlayerView()<AVAudioPlayerDelegate>

{
    
    AVAudioPlayer *_avAudioPlayer;
    UISlider *_pregressSlider;
    UILabel *_pregressLabel;
    UISlider *_volumeSlider;
    NSTimer *_timer;
    
    
    UIButton *playbutton;
    
    UIButton *stopbutton;
    
    BOOL   isplay;
}


@end

@implementation PlayerView

+ (instancetype)PlayerViewWithFrame:(CGRect)frame
{
    
    return [[self alloc] initWithFrame:frame];
    
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithRed:122/255.0 green:199/255.0 blue:243/255.0 alpha:0.8];
        
        
        [self setUI];
        
        
        
    }
    
    return self;
    
}

-(void)setUI{
    
    playbutton = [[UIButton alloc]init];
    
    playbutton.frame = CGRectMake(0, heightt-44, ScreenWid/2, 44);
    
    playbutton.backgroundColor = [UIColor colorWithRed:208/255.0 green:138/255.0 blue:121/255.0 alpha:1.0];
    
    [playbutton setTitle:@"播放" forState:UIControlStateNormal];
    
    [playbutton addTarget:self action:@selector(controlAVAudioAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:playbutton];
    
    
    stopbutton = [[UIButton alloc]init];
    
    stopbutton.frame = CGRectMake(ScreenWid/2, heightt-44, ScreenWid/2, 44);
    
    stopbutton.backgroundColor =[UIColor colorWithRed:238/255.0 green:238/255.0 blue:244/255.0 alpha:1.0];
    
    [stopbutton setTitle:@"停止" forState:UIControlStateNormal];
    
    [stopbutton addTarget:self action:@selector(controlAVAudioAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:stopbutton];
    
    _pregressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 25, ScreenWid - 130 - 20, 20)];
    [self addSubview: _pregressSlider];
    _pregressSlider.minimumValue = 0.0f;
    _pregressSlider.maximumValue = 1.0f;
    [_pregressSlider addTarget:self action:@selector(pregressChange) forControlEvents:UIControlEventValueChanged];
    _pregressLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWid - 120, 25, 100, 20)];
    _pregressLabel.text = @"00:00/00:00";
    [self addSubview:_pregressLabel];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(playProgress) userInfo:nil repeats:YES];
    
    
    _volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 65, ScreenWid - 130 - 20, 20)];
    [_volumeSlider addTarget:self action:@selector(volumeChange) forControlEvents:UIControlEventValueChanged];
    _volumeSlider.minimumValue = 0.0f;
    _volumeSlider.maximumValue = 10.0f;
    _volumeSlider.value = 1.0f;
    [self addSubview:_volumeSlider];
    UILabel *volumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWid - 120, 65, 100, 20)];
    
    
    
    volumeLabel.text = @"音量";
    [self addSubview:volumeLabel];
    
    
    
    
}

-(void)play :(NSURL*)url {
    
    _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _avAudioPlayer.delegate = self;
    _avAudioPlayer.volume = 1;
    _avAudioPlayer.numberOfLoops = 0;
    
    [_avAudioPlayer prepareToPlay];
    [_avAudioPlayer play];
    
    [playbutton setTitle:@"暂停" forState:UIControlStateNormal];
    
    isplay = YES;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            
                            sizeof(sessionCategory),
                            
                            &sessionCategory);
    
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    
    
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             
                             sizeof (audioRouteOverride),
                             
                             &audioRouteOverride);
    
#pragma clang diagnostic pop
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [audioSession setActive:YES error:nil];
    
    
    
    
}


- (void)controlAVAudioAction : (UIButton *)button {
    
    if (button==playbutton) {
        
        if (!isplay) {
            
            [_avAudioPlayer play];
            
            [playbutton setTitle:@"暂停" forState:UIControlStateNormal];
            
        }
        else
        {
            
            [_avAudioPlayer pause];
            
            [playbutton setTitle:@"播放" forState:UIControlStateNormal];
            
        }
        
        isplay = !isplay;
        
    }
    
    if (button== stopbutton) {
        
        _avAudioPlayer.currentTime = 0;
        [_avAudioPlayer stop];
        
        
        self.headviewBlock();
        
    }
    
}

- (void)pregressChange{
    
    _avAudioPlayer.currentTime = _pregressSlider.value * _avAudioPlayer.duration;
}

- (void)playProgress {
    
    NSString *currentMStr = [self FormatTime:_avAudioPlayer.currentTime / 60];
    NSString *currentSStr = [self FormatTime:(int)_avAudioPlayer.currentTime % 60];
    NSString *durationMStr = [self FormatTime:_avAudioPlayer.duration / 60];
    NSString *durationSStr = [self FormatTime:(int)_avAudioPlayer.duration % 60];
    _pregressLabel.text = [NSString stringWithFormat:@"%@:%@/%@:%@",currentMStr,currentSStr,durationMStr,durationSStr];
    _pregressSlider.value = _avAudioPlayer.currentTime / _avAudioPlayer.duration;
}
- (NSString *)FormatTime: (int)time {
    
    if (time < 10) {
        return  [NSString stringWithFormat:@"0%d",time];
    }else {
        return  [NSString stringWithFormat:@"%d",time];
    }
}


- (void)volumeChange {
    _avAudioPlayer.volume = _volumeSlider.value;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    _timer = nil;
    [_timer invalidate];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    [_avAudioPlayer pause];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    [_avAudioPlayer play];
}

@end
