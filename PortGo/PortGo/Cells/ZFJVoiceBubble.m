//
//  ZFJVoiceBubble.m
//  打分界面
//
//  Created by ZFJ on 2017/3/8.
//  Copyright © 2017年 ZFJ. All rights reserved.
//

#import "ZFJVoiceBubble.h"
#import <AVFoundation/AVFoundation.h>

#define KhornImgViewWID 10.0
#define KhornImgViewHEI 13.0
#define KZFJVoiceSpace  8.0
#define KTimeLabWID     28.0
#define KBarDownView    36.0
#define kDelayTime      0.5

#define UIImageNamed(imageName) [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAutomatic]

#define ScreenHeight   [UIScreen mainScreen].bounds.size.height
#define ScreenWidth    [UIScreen mainScreen].bounds.size.width

@interface ZFJVoiceBubble () <AVAudioPlayerDelegate>{
    NSTimer *_myTimer;
}

@property (nonatomic,strong) UIImageView    *hornImgView;
@property (nonatomic,strong) UILabel        *timeLab;

@property (nonatomic,strong) UIView         *barDownView;
@property (nonatomic,strong) UIButton       *rightCloseBtn;
@property (nonatomic,strong) UILabel        *barTitleLab;
@property (nonatomic,strong) UIImageView    *barTitleImg;
@property (nonatomic,strong) UIView         *progressBar;

@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AVURLAsset    *asset;
@property (strong, nonatomic) NSArray       *animationImages;
@property (weak  , nonatomic) UIButton      *contentButton;

- (void)initialize;
- (void)voiceClicked:(id)sender;
- (void)bubbleShouldStop:(NSNotification *)notification;

@end

@implementation ZFJVoiceBubble

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize{
    self.clipsToBounds = NO;
    
    self.hornImgView.hidden = !_isShowLeftImg;
    [self addSubview:self.hornImgView];
    
    //#F2FFE9 100% #D4F4C9 100%
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithRed:0.949 green:1.000 blue:0.914 alpha:1.00];
    [button addTarget:self action:@selector(voiceClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font                = [UIFont systemFontOfSize:12];
    button.adjustsImageWhenHighlighted    = YES;
    button.imageView.animationDuration    = 2.0;
    button.imageView.animationRepeatCount = 30;
    button.imageView.clipsToBounds        = NO;
    button.imageView.contentMode          = UIViewContentModeCenter;
    button.contentHorizontalAlignment     = UIControlContentHorizontalAlignmentRight;
    button.layer.borderColor = [UIColor colorWithRed:0.831 green:0.957 blue:0.788 alpha:1.00].CGColor;
    button.layer.borderWidth = 0.5;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = self.frame.size.height/2;
    [button setImage:UIImageNamed(@"fs_icon_wave_2") forState:UIControlStateNormal];
    [self addSubview:button];
    self.contentButton = button;
    
    [self addSubview:self.timeLab];
}

- (UIView *)barDownView{
    if(_barDownView == nil){
        //#E5F6DD 100%
        _barDownView = [[UIView alloc]init];
        _barDownView.frame = self.isHaveBar ? CGRectMake(0, 64, ScreenWidth, KBarDownView) : CGRectMake(0, 0, ScreenWidth, KBarDownView);
        _barDownView.backgroundColor = [UIColor colorWithRed:0.898 green:0.965 blue:0.867 alpha:0.89];
        [_barDownView addSubview:self.rightCloseBtn];
        UIFont *font = [UIFont fontWithName:@"STHeitiSC-Light" size:14];
        CGFloat barTitleLabWid = [self dynamicHeight:_userName width:2000 height:15 font:font].size.width;
        CGFloat barTitleLabX = (ScreenWidth - barTitleLabWid - 20)/2;
        CGFloat barTitleLabY = (KBarDownView - 20)/2;
        self.barTitleLab.frame = CGRectMake(barTitleLabX, barTitleLabY, barTitleLabWid, 20);
        self.barTitleImg.frame = CGRectMake(barTitleLabX + barTitleLabWid, barTitleLabY, 20, 20);
        [_barDownView addSubview:self.barTitleLab];
        [_barDownView addSubview:self.barTitleImg];
        [_barDownView addSubview:self.progressBar];
    }
    return _barDownView;
}

#pragma mark - 进度条
- (UIView *)progressBar{
    if(_progressBar == nil){
        //#02F932 100%
        _progressBar = [[UIView alloc]init];
        _progressBar.backgroundColor = [UIColor colorWithRed:0.008 green:0.976 blue:0.196 alpha:1.00];
        _progressBar.frame = CGRectMake(0, KBarDownView - 2, 0, 2);
    }
    return _progressBar;
}

//#3FC512 100%
- (UILabel *)barTitleLab{
    if(_barTitleLab == nil){
        _barTitleLab = [[UILabel alloc]init];
        _barTitleLab.font = [UIFont fontWithName:@"STHeitiSC-Light" size:14];
        _barTitleLab.textColor = [UIColor colorWithRed:0.247 green:0.773 blue:0.071 alpha:1.00];
    }
    return _barTitleLab;
}

- (UIImageView *)barTitleImg{
    if(_barTitleImg == nil){
        _barTitleImg = [[UIImageView alloc]init];
        _barTitleImg.image = UIImageNamed(@"fs_icon_wave_2");
    }
    return _barTitleImg;
}

- (void)setUserName:(NSString *)userName{
    if (userName != _userName){
        _userName = userName;
        self.barTitleLab.text = userName;
        UIFont *font = [UIFont fontWithName:@"STHeitiSC-Light" size:14];
        CGFloat barTitleLabWid = [self dynamicHeight:userName width:2000 height:20 font:font].size.width;
        CGFloat barTitleLabX = (ScreenWidth - barTitleLabWid - 20)/2;
        CGFloat barTitleLabY = (KBarDownView - 20)/2;
        self.barTitleLab.frame = CGRectMake(barTitleLabX, barTitleLabY, barTitleLabWid, 20);
        self.barTitleImg.frame = CGRectMake(CGRectGetMaxY(self.barTitleLab.frame), barTitleLabY, 20, 20);
    }
}

- (UILabel *)timeLab{
    if(_timeLab == nil){
        //#75D337 100%
        _timeLab = [[UILabel alloc]init];
        _timeLab.textAlignment = NSTextAlignmentRight;
        _timeLab.font = [UIFont fontWithName:@"STHeitiSC-Light" size:14];
        _timeLab.textColor = [UIColor colorWithRed:0.459 green:0.827 blue:0.216 alpha:1.00];
        _timeLab.text = @"0\"";
    }
    return _timeLab;
}

- (UIImageView *)hornImgView{
    if(_hornImgView == nil){
        _hornImgView = [[UIImageView alloc]init];
        _hornImgView.image = UIImageNamed(@"ZFJHornImg");
    }
    return _hornImgView;
}

- (UIButton *)rightCloseBtn{
    if(_rightCloseBtn == nil){
        //#40C712 100%
        _rightCloseBtn = [[UIButton alloc]init];
        _rightCloseBtn.frame = CGRectMake(ScreenWidth - KBarDownView, 0, KBarDownView, KBarDownView);
        [_rightCloseBtn setTitleColor:[UIColor colorWithRed:0.251 green:0.780 blue:0.071 alpha:1.00] forState:UIControlStateNormal];
        _rightCloseBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:14];
        [_rightCloseBtn setTitle:@"x" forState:UIControlStateNormal];
        [_rightCloseBtn addTarget:self action:@selector(rightCloseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightCloseBtn;
}

#pragma mark - 移除头部视图
- (void)rightCloseBtnClick:(UIButton *)button{
    [self.barDownView removeFromSuperview];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //头部视图
    self.barDownView.frame = self.isHaveBar ? CGRectMake(0, 64, ScreenWidth, KBarDownView) : CGRectMake(0, 0, ScreenWidth, KBarDownView);
    //左边语言图标
    CGFloat hornImgViewWID = self.isShowLeftImg?KhornImgViewWID:0;
    self.hornImgView.hidden = !_isShowLeftImg;
    self.hornImgView.frame = CGRectMake(0, (self.frame.size.height - KhornImgViewHEI)/2, hornImgViewWID, KhornImgViewHEI);
    //时间
    self.timeLab.frame = CGRectMake(self.frame.size.width - KTimeLabWID, 0, KTimeLabWID, self.frame.size.height);
    //语言按钮
    CGFloat voiceBtnWID = self.frame.size.width - hornImgViewWID - KZFJVoiceSpace - KTimeLabWID;
    self.contentButton.frame = CGRectMake(CGRectGetMaxX(self.hornImgView.frame) + KZFJVoiceSpace, 0, voiceBtnWID, self.frame.size.height);
    self.contentButton.layer.cornerRadius = self.frame.size.height/2;
    
    if (self.timeLab.text.length>0) {
        _contentButton.imageEdgeInsets = UIEdgeInsetsMake(0,- voiceBtnWID + 50,0,voiceBtnWID - 50 + 25);
        NSInteger textPadding = _invert ? 2 : 4;
        _contentButton.titleEdgeInsets = UIEdgeInsetsMake(self.frame.size.height , textPadding,self.frame.size.height, - textPadding);
        self.layer.transform = _invert ? CATransform3DMakeRotation(M_PI, 0, 1.0, 0) : CATransform3DIdentity;
        _contentButton.titleLabel.layer.transform = _invert ? CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0) : CATransform3DIdentity;
        _timeLab.layer.transform = _invert ? CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0) : CATransform3DIdentity;
        _timeLab.textAlignment = _invert ? NSTextAlignmentLeft:NSTextAlignmentRight;
    }
}

#pragma mark - Setter & Getter
- (void)setInvert:(BOOL)invert{
    if (_invert != invert) {
        _invert = invert;
        [self setNeedsLayout];
    }
}

- (void)setIsShowLeftImg:(BOOL)isShowLeftImg{
    if(_isShowLeftImg != isShowLeftImg){
        _isShowLeftImg = isShowLeftImg;
        [self setNeedsLayout];
    }
}

- (void)setContentURL:(NSURL *)contentURL{
    if (![_contentURL isEqual:contentURL]) {
        _contentURL = contentURL;
        if (_player.isPlaying) {
            [self stop];
        }
        _contentButton.enabled = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            _asset = [[AVURLAsset alloc] initWithURL:contentURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
            CMTime duration = _asset.duration;
            NSInteger seconds = CMTimeGetSeconds(duration);
            if (seconds > 60) {
                NSLog(@"A voice audio should't last longer than 60 seconds");
                _contentURL = nil;
                _asset = nil;
                return;
            }
            NSData *data = [NSData dataWithContentsOfURL:contentURL];
            if(_player == nil){
                _player = [[AVAudioPlayer alloc] initWithData:data error:NULL];
            }
            _player.delegate = self;
            [_player prepareToPlay];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.timeLab.text = [NSString stringWithFormat:@"%@\"",@(seconds)];
                _contentButton.enabled = YES;
                [self setNeedsLayout];
            });
        });
    }
}

#pragma mark - 开始定时器
- (void)startTimer{
    if([_myTimer isValid]){
        [_myTimer invalidate];
        _myTimer = nil;
    }
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playProgress) userInfo:nil repeats:YES];
}
#pragma mark - 结束定时器
- (void)setopTimer{
    [_myTimer invalidate];
    _myTimer = nil;
}

#pragma mark - 播放进度条
- (void)playProgress {
    CGFloat progress = _player.currentTime/_player.duration;
    CGRect frame = self.progressBar.frame;
    frame.size.width = progress * ScreenWidth;
    self.progressBar.frame = frame;
}

#pragma mark - AVAudioPlayer Delegate
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    [self pause];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    [self play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self stopAnimating];
}

#pragma mark - Nofication
- (void)bubbleShouldStop:(NSNotification *)notification{
    if (_player.isPlaying) {
        [self stop];
    }
}

#pragma mark - Target Action
- (void)voiceClicked:(id)sender{
    if (_player.playing && _contentButton.imageView.isAnimating) {
        [self stop];
    }else{
        [self play];
        if (_delegate && [_delegate respondsToSelector:@selector(voiceBubbleDidStartPlaying:)]) {
            [_delegate voiceBubbleDidStartPlaying:self];
        }
    }
}

#pragma mark - Public
- (void)startAnimating{
    if([self.delegate respondsToSelector:@selector(voiceBubbleStratOrStop:)]){
        [self.delegate voiceBubbleStratOrStop:YES];
    }
    //添加头部视图
 //   [[UIApplication sharedApplication].keyWindow addSubview:self.barDownView];
    
    //启动定时器
    [self startTimer];
    
    UIImage *image0 = UIImageNamed(@"fs_icon_wave_0");
    UIImage *image1 = UIImageNamed(@"fs_icon_wave_1");
    UIImage *image2 = UIImageNamed(@"fs_icon_wave_2");
    NSArray *animationImages = @[image0, image1, image2];
    
    if (!_contentButton.imageView.isAnimating) {
        _contentButton.imageView.animationImages = animationImages;
        _contentButton.imageView.animationDuration = animationImages.count * 0.7;
        [_contentButton.imageView startAnimating];
    }
    
    if (!self.barTitleImg.isAnimating) {
        self.barTitleImg.animationImages = animationImages;
        self.barTitleImg.animationDuration = animationImages.count * 0.7;
        [self.barTitleImg startAnimating];
    }
}

- (void)stopAnimating{
    if([self.delegate respondsToSelector:@selector(voiceBubbleStratOrStop:)]){
        [self.delegate voiceBubbleStratOrStop:NO];
    }
    //移除头部视图
  //  [self.barDownView removeFromSuperview];
    
    //停止定时器
    [self setopTimer];
    
    if (_contentButton.imageView.isAnimating) {
        [_contentButton.imageView stopAnimating];
    }
    if (self.barTitleImg.isAnimating) {
        [self.barTitleImg stopAnimating];
    }
}

- (void)play{
    if (!_contentURL) {
        NSLog(@"没有设置URL");
        return;
    }
    if (!_player.playing) {
        [_player play];
        [self startAnimating];
    }
}

- (void)pause{
    if (_player.playing) {
        [_player pause];
        [self stopAnimating];
    }
}

- (void)stop{
    if (_player.playing) {
        [_player stop];
        _player.currentTime = 0;
        [self stopAnimating];
    }
}

#pragma mark - 动态计算宽高
- (CGRect)dynamicHeight:(NSString *)str width:(CGFloat)width height:(CGFloat)height font:(UIFont *)font{
    if(str==nil||[str isEqual:[NSNull null]]){
        str = @" ";
    }
    NSMutableParagraphStyle*style = [[NSMutableParagraphStyle alloc]init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    NSDictionary*dict = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:style};
    NSStringDrawingOptions opts = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
    CGRect rect = [str boundingRectWithSize:CGSizeMake(width, height) options:opts attributes:dict context:nil];
    return rect;
}

@end
