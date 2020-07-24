//
//  PlayViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/11/20.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "PlayViewController.h"

#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import "Waver.h"




@interface PlayViewController ()<AVAudioPlayerDelegate>
{
    
        UILabel * titlelabel;
    
        UISlider *_pregressSlider; // 播放控制
        UILabel *_pregressLabel; // 进度
       UILabel *_lengthpregressLabel; // 进度
    
    
    UIButton * playbutton;
    
    UIButton * nextbutton;
    
    UIButton *lastbutton;
    
     AVAudioPlayer *_avAudioPlayer; // 播放器palyer
    
    NSTimer *_timer; // 监控音频播放进度
    
      BOOL   isplay;
    
}

@property  Waver * waver;

@property UIImageView *imageview;



@end

@implementation PlayViewController


- (UIStatusBarStyle)preferredStatusBarStyle {
    //    return UIStatusBarStyleLightContent;
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(50, 50, 50);
    
    
    
    [self initnav];
    
    [self initplayview];
    
    
    [self playfirst];
    
    
    
   
    // Do any additional setup after loading the view.
}


-(void)playfirst{
    
    
        NSURL *fileURL= nil;
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        NSString *path = [documentDir stringByAppendingPathComponent:[_audioArr objectAtIndex:_index]];
    
        NSLog(@"_audioArr _index===%@",[_audioArr objectAtIndex:_index]);
    
        fileURL = [NSURL fileURLWithPath:path];

    
    _waver .hidden = NO;
    _imageview .hidden = YES;
    
        [self play:fileURL];
    
       [self setgray];
    
}

-(void)initnav{
    
    UIButton *navbutton = [[UIButton alloc]init];
    
    [navbutton setImage:[UIImage imageNamed:@"record_back_ico"] forState:UIControlStateNormal];
    
    [navbutton setTitle:NSLocalizedString(@"All recording files", @"All recording files") forState:UIControlStateNormal];
    
    // navbutton.backgroundColor = [UIColor yellowColor];
    
    [navbutton addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:navbutton];
    
    [navbutton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
        make.left.mas_equalTo(self.view.mas_left).with.offset(0);
        
        make.top.mas_equalTo(self.view.mas_top).with.offset(25);
        
        
        make.width.equalTo(@(150));
        
        make.height.equalTo(@(40));
        
        
        
        
    }];
    
    
    
    
    titlelabel = [[UILabel alloc]init];
    [self.view addSubview:titlelabel];
    
    titlelabel.textColor = [UIColor whiteColor];
    
    titlelabel.textAlignment = NSTextAlignmentCenter;
    
    titlelabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    
    
   // titlelabel.text = @"1asdfaf-DAGA241415r112.mp3";
    
      titlelabel.text = [_audioArr objectAtIndex:_index];
    
    [titlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
        make.left.mas_equalTo(self.view.mas_left).with.offset(0);
        make.right.mas_equalTo(self.view.mas_right).with.offset(0);
//        make.top.mas_equalTo(self.view.mas_top).with.offset(25);
//
        make.top.mas_equalTo(self.view.mas_top).with.offset(50);
        
        
        make.height.equalTo(@(100));
        
    }];
    
    
    
    
    
    _imageview = [[UIImageView alloc]init];
    
    [_imageview setImage:[UIImage imageNamed:@"record_bg_img"]];
    
    [self.view addSubview:_imageview];
    
    
    [_imageview mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
        
        make.width.equalTo(@(147));
        make.height.equalTo(@(75));
        
        make.centerX.equalTo(self.view.mas_centerX);
        
        make.centerY.equalTo(self.view.mas_centerY);
        
    }];
    
    
    
    _waver = [[Waver alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)/2.0 - 50.0, CGRectGetWidth(self.view.bounds), 100.0)];
    
    
    _waver.waverLevelCallback = ^(Waver * waver) {
        
        
        
        waver.level = 0.3;
        
        
        
    };
    
    [self.view addSubview:_waver];
    
    
    
    
}






-(void)initplayview{
    
   // (2)初始化播放控制
    _pregressSlider = [[UISlider alloc] initWithFrame:CGRectMake(60, ScreenHeight-100, ScreenWid-120, 20)];
    [self.view addSubview: _pregressSlider];
    _pregressSlider.minimumValue = 0.0f;
    _pregressSlider.maximumValue = 1.0f;
    [_pregressSlider addTarget:self action:@selector(pregressChange) forControlEvents:UIControlEventValueChanged];
    
    
 //   UIImage *imagea=[self OriginImage:[UIImage imageNamed:@"pmgressbar_circular@3x"] scaleToSize:CGSizeMake(15, 15)];
 
    
    
    [_pregressSlider  setThumbImage:[UIImage imageNamed:@"pmgressbar_circular"] forState:UIControlStateNormal];
   [_pregressSlider setThumbImage:[UIImage imageNamed:@"pmgressbar_circular"] forState:UIControlStateHighlighted];
    
    
//    [_pregressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
//
//
//        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(-80);
//        make.width.equalTo(@(150));
//        make.height.equalTo(@(20));
//
//        make.centerX.equalTo(self.view.mas_centerX);
//
//       // make.centerY.equalTo(self.view.mas_centerX);
//
//    }];
    
    
    // (3)用NSTimer来监控音频播放进度
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(playProgress) userInfo:nil repeats:YES];
    
    
    _pregressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight-100, 60, 20)];
    _pregressLabel.text = @"00:00";
     _pregressLabel.textAlignment =NSTextAlignmentCenter;
    
    _pregressLabel.font = [UIFont systemFontOfSize:12];
    
    _pregressLabel.textColor = [UIColor whiteColor];
    
    [self.view  addSubview:_pregressLabel];
    
//    [_pregressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
//
//       make.left.equalTo(self.view.mas_left).with.offset(15);
//
//        make.width.equalTo(@(50));
//        make.height.equalTo(@(20));
//
//
//         make.centerY.equalTo(_pregressSlider.mas_centerY);
//
//    }];
    
    
    _lengthpregressLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWid-60, ScreenHeight-100, 60, 20)];
    _lengthpregressLabel.text = @"00:00";
    _lengthpregressLabel.textColor = [UIColor whiteColor];
      _lengthpregressLabel.font = [UIFont systemFontOfSize:12];
    _lengthpregressLabel.textAlignment =NSTextAlignmentCenter;
    
    [self.view  addSubview:_lengthpregressLabel];
    
//    [_lengthpregressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//
//        make.right.equalTo(self.view.mas_right).with.offset(-15);
//
//        make.width.equalTo(@(50));
//        make.height.equalTo(@(20));
//
//
//        make.centerY.equalTo(_pregressSlider.mas_centerY);
//
//    }];
    
    
    playbutton = [[UIButton alloc]init];
    
    playbutton.frame = CGRectMake((ScreenWid-50)/2, ScreenHeight-65, 50, 50);
    
    [playbutton addTarget:self action:@selector(controlAVAudioAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [playbutton setImage:[UIImage imageNamed:@"record_play_ico"] forState:UIControlStateNormal];
    [self.view addSubview:playbutton];
    
    
    nextbutton = [[UIButton alloc]init];
    
    //nextbutton.frame = CGRectMake((ScreenWid-50)/2, ScreenHeight-75, 25 , 25);
    
    [nextbutton setImage:[UIImage imageNamed:@"record_speed_ico"] forState:UIControlStateNormal];
    
    [nextbutton addTarget:self action:@selector(controlAVAudioAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:nextbutton];
    
        [nextbutton mas_makeConstraints:^(MASConstraintMaker *make) {
    
            make.left.equalTo(playbutton.mas_right).with.offset(40);
    
            make.width.equalTo(@(35));
            make.height.equalTo(@(35));
    
    
            make.centerY.equalTo(playbutton.mas_centerY);
    
        }];
    
    
    lastbutton = [[UIButton alloc]init];
    
    [lastbutton addTarget:self action:@selector(controlAVAudioAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //nextbutton.frame = CGRectMake((ScreenWid-50)/2, ScreenHeight-75, 25 , 25);
    
    [lastbutton setImage:[UIImage imageNamed:@"record_slow_ico"] forState:UIControlStateNormal];
    [self.view addSubview:lastbutton];
    
    [lastbutton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(playbutton.mas_left).with.offset(-40);
        
        make.width.equalTo(@(35));
        make.height.equalTo(@(35));
        
        
        make.centerY.equalTo(playbutton.mas_centerY);
        
    }];
    
    
    
    
}


#pragma mark -
#pragma mark playdelegate


-(void)play :(NSURL*)url {
    
    // 2.播放本地音频文件
    // (1)从boudle路径下读取音频文件 陈小春 - 独家记忆文件名，mp3文件格式
    //   NSString *path = [[NSBundle mainBundle] pathForResource:@"Record_20171116-155936" ofType:@"wav"];
    // (2)把音频文件转化成url格式
    //   NSURL *url = [NSURL fileURLWithPath:path];
    // (3)初始化音频类 并且添加播放文件
    _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    // (4) 设置代理
    _avAudioPlayer.delegate = self;
    // (5) 设置初始音量大小 默认1，取值范围 0~1
    _avAudioPlayer.volume = 1;
    // (6)设置音乐播放次数 负数为一直循环，直到stop，0为一次，1为2次，以此类推
    _avAudioPlayer.numberOfLoops = 0;
    // (7)准备播放
    [_avAudioPlayer prepareToPlay];
    
    
    //初始化播放器的时候如下设置
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            
                            sizeof(sessionCategory),
                            
                            &sessionCategory);
    
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    
    
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             
                             sizeof (audioRouteOverride),
                             
                             &audioRouteOverride);
    
    #pragma clang diagnostic pop
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    //默认情况下扬声器播放
    
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [audioSession setActive:YES error:nil];
    
    [_avAudioPlayer play];
    
   // [playbutton setTitle:@"暂停" forState:UIControlStateNormal];
    
     [playbutton setImage:[UIImage imageNamed:@"record_pause_ico"] forState:UIControlStateNormal];
    
    isplay = YES;
    
    
    
    
    
    
}


// 音频控制
- (void)controlAVAudioAction : (UIButton *)button {
    
    
    // 播放
    
    
    if (button==playbutton) {
        
        if (!isplay) {
            
            [_avAudioPlayer play];
            
       [playbutton setImage:[UIImage imageNamed:@"record_pause_ico"] forState:UIControlStateNormal];
            
            
            _imageview .hidden = YES;
            
            _waver.hidden = NO;
            
            
        }
        else
        {
            
            _imageview .hidden = NO;
            
            _waver.hidden = YES;
            
            
            
            [_avAudioPlayer pause];
            
         [playbutton setImage:[UIImage imageNamed:@"record_play_ico"] forState:UIControlStateNormal];
            
        }
        
        isplay = !isplay;
        
    }
    
    
    //
    if (button== nextbutton) {

        
        _index =_index+1;
        
//        if (_index== _audioArr.count) {
//
//            _index=0;
//        }
        
        NSURL *fileURL= nil;
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        NSString *path = [documentDir stringByAppendingPathComponent:[_audioArr objectAtIndex:_index]];
        fileURL = [NSURL fileURLWithPath:path];
        
        [self play:fileURL];

      
    }
    
    
    if (button== lastbutton) {
        
        
        _index =_index-1;
        
//        if (_index== -1) {
//
//            _index=_audioArr.count-1;
//
//        }
        
        NSURL *fileURL= nil;
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        NSString *path = [documentDir stringByAppendingPathComponent:[_audioArr objectAtIndex:_index]];
        fileURL = [NSURL fileURLWithPath:path];
        
        [self play:fileURL];
        
    
    }
    
    
    
    titlelabel.text = [_audioArr objectAtIndex:_index];
    
    
    [self setgray];
    
}


-(void)setgray{
    
    if (_index == 0) {
        
        [lastbutton setImage:[UIImage imageNamed:@"record_slow_disabled"] forState:UIControlStateNormal];
        
            lastbutton .userInteractionEnabled = NO;
        
    }
    else
    {
        [lastbutton setImage:[UIImage imageNamed:@"record_slow_ico"] forState:UIControlStateNormal];
        
        lastbutton .userInteractionEnabled = YES;
        
    }
    
    if (_index == _audioArr.count-1) {
        
            [nextbutton setImage:[UIImage imageNamed:@"record_speed_disabled"] forState:UIControlStateNormal];
        
            nextbutton .userInteractionEnabled = NO;
        
        
    }else
    {
        [nextbutton setImage:[UIImage imageNamed:@"record_speed_ico"] forState:UIControlStateNormal];
        
        nextbutton .userInteractionEnabled = YES;
        
    }
    
    
}


-(void)pregressChange{
    
    _avAudioPlayer.currentTime = _pregressSlider.value * _avAudioPlayer.duration;
    
}

// 播放进度条
- (void)playProgress {
    // 更改当前播放时间
    NSString *currentMStr = [self FormatTime:_avAudioPlayer.currentTime / 60];
    NSString *currentSStr = [self FormatTime:(int)_avAudioPlayer.currentTime % 60];
    NSString *durationMStr = [self FormatTime:_avAudioPlayer.duration / 60];
    NSString *durationSStr = [self FormatTime:(int)_avAudioPlayer.duration % 60];
    _pregressLabel.text = [NSString stringWithFormat:@"%@:%@",currentMStr,currentSStr];
    // 播放进度条
    _pregressSlider.value = _avAudioPlayer.currentTime / _avAudioPlayer.duration;
    
    
    
    _lengthpregressLabel.text =[NSString stringWithFormat:@"%@:%@",durationMStr,durationSStr];
    
    
    
}
- (NSString *)FormatTime: (int)time {
    
    if (time < 10) {
        return  [NSString stringWithFormat:@"0%d",time];
    }else {
        return  [NSString stringWithFormat:@"%d",time];
    }
}
#pragma mark - AVAudioPlayerDelegate
// 当播放完成时执行的代理
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    NSLog(@"audioPlayerDidFinishPlaying");
    _timer = nil;
    [_timer invalidate];
    
    
    [playbutton setImage:[UIImage imageNamed:@"record_play_ico"] forState:UIControlStateNormal];
    
    
    isplay = NO;
    
    _waver .hidden = YES;
    _imageview .hidden = NO;
    
    
    
    
}
// 当播放发生错误时调用
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSLog(@"播放发生错误%@",error);
    
    _waver .hidden = YES;
    _imageview .hidden = NO;
}
// 当播放器发生中断时调用 如来电
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
    NSLog(@"audioPlayerBeginInterruption");
    // 暂停播放 用户不暂停，系统也会帮你暂停。但是如果你暂停了，等来电结束，需要再开启
    [_avAudioPlayer pause];
    
    _waver .hidden = YES;
    _imageview .hidden = NO;
}
// 当中断停止时调用 如来电结束
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    
    NSLog(@"audioPlayerEndInterruption");
    // 你可以帮用户开启 也可以什么都不执行，让用户自己决定
    [_avAudioPlayer play];
}
-(void)dissmiss{
    
    _avAudioPlayer.currentTime = 0;
    [_avAudioPlayer stop];
    
    [_waver removeFromSuperview];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaleImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}
@end
