//
//  testAMRViewController.m
//  PortSIP
//
//  Created by 今言网络 on 2018/4/23.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import "testAMRViewController.h"
#import <AVFoundation/AVFoundation.h>

#import <CoreAudio/CoreAudioTypes.h>

@interface testAMRViewController ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>

    
 @property   AVAudioRecorder  *recoder;
    
    @property (nonatomic, strong) AVAudioPlayer *player;
    

@end

@implementation testAMRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton* luyinbutton  = [[UIButton alloc]init];
    
    [luyinbutton addTarget:self action:@selector(luyin) forControlEvents:UIControlEventTouchUpInside];
    
    luyinbutton.backgroundColor = [UIColor redColor];
    
    luyinbutton.frame = CGRectMake(100, 100, 100, 50);
    
    [self.view addSubview:luyinbutton];
    
    
    
    
    UIButton* stopbutton  = [[UIButton alloc]init];
    
    [stopbutton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    
    stopbutton.backgroundColor = [UIColor orangeColor];
    
    stopbutton.frame = CGRectMake(100, 200, 100, 50);
    
    [self.view addSubview:stopbutton];
    
    
    
    
    UIButton* bofangbutton  = [[UIButton alloc]init];
    
    [bofangbutton addTarget:self action:@selector(bofang) forControlEvents:UIControlEventTouchUpInside];
    
    bofangbutton.backgroundColor = [UIColor yellowColor];
    
    bofangbutton.frame = CGRectMake(100, 300, 100, 50);
    
    [self.view addSubview:bofangbutton];
    
    //[self recoderinit];
    
    
    UIButton* fanhuibutton  = [[UIButton alloc]init];
    
    [fanhuibutton addTarget:self action:@selector(fanhui) forControlEvents:UIControlEventTouchUpInside];
    
    fanhuibutton.backgroundColor = [UIColor yellowColor];
    
    fanhuibutton.frame = CGRectMake(100, 400, 100, 50);
    
    [self.view addSubview:fanhuibutton];
    
    
    
    // Do any additional setup after loading the view.
}

-(void)fanhui{
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    
}

-(void)recoderinit{
    
    NSLog(@"recoder");
    
    
    if (_recoder == nil) {
        
        NSError *error = nil;
        
        _recoder = [[AVAudioRecorder alloc]initWithURL:[self setLocalRecordSoundsFile] settings:[self setRecordSetting] error:&error];
        
        _recoder.delegate =self;
        
        
        [_recoder prepareToRecord];
        
    }
    
}


-(void)luyin{
    
    
        [self recoderinit];
    
    
    
       NSLog(@"luyin");
    
        BOOL record = [_recoder record];
    
    if (!record) {
        
        NSLog(@"录音错误");
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        NSError *error = nil;
        
        [session setCategory:AVAudioSessionCategoryRecord error:&error];
        
        if(error){
            
            NSLog(@"录音错误说明%@", [error description]);
        }
    }
    
}


-(void)stop{
    
    NSLog(@"stop");
    
       [_recoder stop];
    
}

-(void)bofang{
    
    NSLog(@"bofang");
    
    
//    if (!self.player) {
    
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        NSError *error = nil;
        
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        if(error){
            
            NSLog(@"播放错误说明%@", [error description]);
        }
        
        NSURL *url;
        

        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        NSString *path = [documentDir stringByAppendingPathComponent:@"sound.wav"];
        
        url = [NSURL fileURLWithPath:path];
        
        NSLog(@"url=====%@",url);
        
        if (url == nil) {
            
            return;
        }
        
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        
        self.player.delegate = self;
        
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
         
        }
        
 //   }
    
    [self.player prepareToPlay];
    
    [self.player play];
    
//    self.FinishPlaying = FinishPlaying;
    
}
#pragma mark 设置录音

- (void)setAudioSession

{
    
    NSError *error = nil;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    [session setActive:YES error:&error];
    
    
    
}

//设置本地文件路径

- (NSURL *)setLocalRecordSoundsFile

{
    
    NSString *urlPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    urlPath = [urlPath stringByAppendingPathComponent:@"sound.wav"];
    NSLog(@"urlPath=%@",urlPath);
    
    return [NSURL fileURLWithPath:urlPath];
    
}



//设置配置

- (NSDictionary *)setRecordSetting

{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    //设置录音格式
    
    [dic setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    
    //设置录音采样率 8000shi 电话采样率 对于一般录音已经够了
    
    [dic setObject:@(44100) forKey:AVSampleRateKey];
    
    //设置通道，这里采用单通道
    
    [dic setObject:@(1) forKey:AVNumberOfChannelsKey];
    
    //每个采样点位数 分别为 8 16 24 32
    
    [dic setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    
    //是否采用浮点数采样
    
    [dic setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    
    return dic;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
