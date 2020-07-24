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
    
    UISlider *_pregressSlider;
    UILabel *_pregressLabel;
    UILabel *_lengthpregressLabel;
    
    
    UIButton * playbutton;
    
    UIButton * nextbutton;
    
    UIButton *lastbutton;
    
    AVAudioPlayer *_avAudioPlayer;
    
    NSTimer *_timer;
    
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
    
    _pregressSlider = [[UISlider alloc] initWithFrame:CGRectMake(60, ScreenHeight-100, ScreenWid-120, 20)];
    [self.view addSubview: _pregressSlider];
    _pregressSlider.minimumValue = 0.0f;
    _pregressSlider.maximumValue = 1.0f;
    [_pregressSlider addTarget:self action:@selector(pregressChange) forControlEvents:UIControlEventValueChanged];
    
    [_pregressSlider  setThumbImage:[UIImage imageNamed:@"pmgressbar_circular"] forState:UIControlStateNormal];
    [_pregressSlider setThumbImage:[UIImage imageNamed:@"pmgressbar_circular"] forState:UIControlStateHighlighted];
    
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(playProgress) userInfo:nil repeats:YES];
    
    
    _pregressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight-100, 60, 20)];
    _pregressLabel.text = @"00:00";
    _pregressLabel.textAlignment =NSTextAlignmentCenter;
    
    _pregressLabel.font = [UIFont systemFontOfSize:12];
    
    _pregressLabel.textColor = [UIColor whiteColor];
    
    [self.view  addSubview:_pregressLabel];
    
    
    _lengthpregressLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWid-60, ScreenHeight-100, 60, 20)];
    _lengthpregressLabel.text = @"00:00";
    _lengthpregressLabel.textColor = [UIColor whiteColor];
    _lengthpregressLabel.font = [UIFont systemFontOfSize:12];
    _lengthpregressLabel.textAlignment =NSTextAlignmentCenter;
    
    [self.view  addSubview:_lengthpregressLabel];
    
    
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
    
    _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _avAudioPlayer.delegate = self;
    _avAudioPlayer.volume = 1;
    _avAudioPlayer.numberOfLoops = 0;
    [_avAudioPlayer prepareToPlay];
    
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
    
    
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [audioSession setActive:YES error:nil];
    
    [_avAudioPlayer play];
    
    
    [playbutton setImage:[UIImage imageNamed:@"record_pause_ico"] forState:UIControlStateNormal];
    
    isplay = YES;
    
    
    
    
    
    
}

- (void)controlAVAudioAction : (UIButton *)button {
    
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
    
    if (button== nextbutton) {
        
        
        _index =_index+1;
        
        NSURL *fileURL= nil;
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        NSString *path = [documentDir stringByAppendingPathComponent:[_audioArr objectAtIndex:_index]];
        fileURL = [NSURL fileURLWithPath:path];
        
        [self play:fileURL];
        
        
    }
    
    
    if (button== lastbutton) {
        
        _index =_index-1;
        
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


- (void)playProgress {
    
    NSString *currentMStr = [self FormatTime:_avAudioPlayer.currentTime / 60];
    NSString *currentSStr = [self FormatTime:(int)_avAudioPlayer.currentTime % 60];
    NSString *durationMStr = [self FormatTime:_avAudioPlayer.duration / 60];
    NSString *durationSStr = [self FormatTime:(int)_avAudioPlayer.duration % 60];
    _pregressLabel.text = [NSString stringWithFormat:@"%@:%@",currentMStr,currentSStr];
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
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    _timer = nil;
    [_timer invalidate];
    
    
    [playbutton setImage:[UIImage imageNamed:@"record_play_ico"] forState:UIControlStateNormal];
    
    
    isplay = NO;
    
    _waver .hidden = YES;
    _imageview .hidden = NO;
}


- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    _waver .hidden = YES;
    _imageview .hidden = NO;
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    [_avAudioPlayer pause];
    
    _waver .hidden = YES;
    _imageview .hidden = NO;
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
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
