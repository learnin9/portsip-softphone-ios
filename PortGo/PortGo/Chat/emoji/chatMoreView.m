//
//  chatMoreView.m
//  PortGo
//
//  Created by 今言网络 on 2018/4/24.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import "chatMoreView.h"
#import "ZXChatBoxItemView.h"
#import "UIView+TL.h"
#import "UIColor_Hex.h"


#define     DEFAULT_CHAT_BACKGROUND_COLOR    WBColor(235.0, 235.0, 235.0, 1.0)
#define     DEFAULT_CHATBOX_COLOR            WBColor(244.0, 244.0, 246.0, 1.0)
#define     DEFAULT_SEARCHBAR_COLOR          WBColor(239.0, 239.0, 244.0, 1.0)
#define     DEFAULT_GREEN_COLOR              WBColor(2.0, 187.0, 0.0, 1.0f)
#define     DEFAULT_TEXT_GRAY_COLOR         [UIColor grayColor]
#define     DEFAULT_LINE_GRAY_COLOR          WBColor(188.0, 188.0, 188.0, 0.6f)

@interface chatMoreView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong)UIButton*  photobutton;
@property (nonatomic, strong)UIButton*  takepicturebutton;
@property (nonatomic, strong)UIButton*  callbutton;
@property (nonatomic, strong)UIButton*  callVideobutton;
@property (nonatomic, strong)UIButton*  filebutton;

@property (nonatomic, strong) UILabel *photobuttonLabel;
@property (nonatomic, strong)UILabel*  takepicturebuttonLabel;
@property (nonatomic, strong)UILabel*  callbuttonLabel;
@property (nonatomic, strong)UILabel*  callVideobuttonLabel;
@property (nonatomic, strong)UILabel*  filebuttonLabel;

@property (nonatomic, strong)UIImageView* photobuttonImage;
@property (nonatomic, strong)UIImageView*  takepicturebuttonImage;
@property (nonatomic, strong)UIImageView*  callbuttonImage;
@property (nonatomic, strong)UIImageView*  callVideobuttonImage;
@property (nonatomic, strong)UIImageView*  filebuttonImage;

@property (nonatomic, strong)UIView*  separatedLine;
@property CGFloat width;

@end


@implementation chatMoreView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor colorWithHexString:@"#f8f8f8"]];
        //        [self addSubview:self.topLine];
        //        [self addSubview:self.scrollView];
        //        [self addSubview:self.pageControl];
        
        [self addSubview:self.photobutton];
        [self addSubview:self.takepicturebutton];
        [self addSubview:self.callbutton];
        [self addSubview:self.callVideobutton];
        
        [self addSubview:self.filebutton];
        
        [self.photobutton addSubview:self.photobuttonImage];
        [self.takepicturebutton addSubview:self.takepicturebuttonImage];
        [self.callbutton addSubview:self.callbuttonImage];
        [self.callVideobutton addSubview:self.callVideobuttonImage];
        [self.filebutton addSubview:self.filebuttonImage];
        
        [self addSubview:self.separatedLine];
        [self addSubview:self.photobuttonLabel];
        [self addSubview:self.takepicturebuttonLabel];
        [self addSubview:self.callbuttonLabel];
        
        [self addSubview:self.callVideobuttonLabel];
        
        [self addSubview:self.filebuttonLabel];
        
    }
    return self;
}

- (void)layoutSubviews{
    [self traitCollectionDidChange:self.traitCollection];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    //    [self.scrollView setFrame:CGRectMake(0, 0.5, frame.size.width, frame.size.height - 18)];
    //    [self.pageControl setFrame:CGRectMake(0, self.frameHeight - 18, frame.size.width, 8)];
    
    CGFloat spacing1 = 30;//left right padding,左右距离屏幕边缘的间距
    CGFloat spacing2 = 25;//clums padding 列间距
    
    CGFloat spacingheader = 20;
    CGFloat spacingtext = 7;
    CGFloat LableHeight = 20;
    
    _width = (ScreenWid-spacing1*2 - spacing2*3)/4;
    
    [self.photobutton setFrame:CGRectMake(spacing1, spacingheader, _width, _width)];
    [self.photobuttonLabel setFrame:CGRectMake(spacing1, spacingheader+_width+7, _width, LableHeight)];
    
    
    [self.takepicturebutton setFrame:CGRectMake(spacing1 + _width  +spacing2, spacingheader, _width, _width)];
    [self.takepicturebuttonLabel setFrame:CGRectMake(spacing1 + _width  +spacing2, spacingheader+_width+7, _width, LableHeight)];
    
    
    [self.callbutton setFrame:CGRectMake(spacing1+_width +spacing2+_width +spacing2, spacingheader, _width, _width)];
    [self.callbuttonLabel setFrame:CGRectMake(spacing1+_width +spacing2+_width +spacing2-5, spacingheader+_width+7, _width+10, LableHeight)];
    
    
    [self.callVideobutton setFrame:CGRectMake(spacing1+_width +spacing2+_width +spacing2+_width +spacing2, spacingheader, _width, _width)];
    [self.callVideobuttonLabel setFrame:CGRectMake(spacing1+_width +spacing2+_width +spacing2+_width +spacing2-5, spacingheader+_width+7, _width+10, LableHeight)];
    
    //row 2
    spacingheader+=_width;
    spacingheader+=LableHeight;
    spacingheader+=spacing2;
    
    [self.filebutton setFrame:CGRectMake(spacing1, spacingheader, _width, _width)];
    [self.filebuttonLabel setFrame:CGRectMake(spacing1, spacingheader+_width+7, _width, 20)];
    
    [self.separatedLine  setFrame:CGRectMake(0, 0, ScreenWid, 0.5)];
    
    
    CGFloat wid2 = 40;
    
    CGFloat header = (_width-40)/2;
    
    
    
    [self.photobuttonImage setFrame:CGRectMake(header, header, wid2, wid2)];
    
    [self.takepicturebuttonImage setFrame:CGRectMake(header, header, wid2, wid2)];
    
    [self.callbuttonImage setFrame:CGRectMake(header, header, wid2, wid2)];
    
    [self.callVideobuttonImage setFrame:CGRectMake(header, header, wid2, wid2)];
    
    //row2
    [self.filebuttonImage setFrame:CGRectMake(header, header, wid2, wid2)];
}


#pragma mark - Public Methods
-(void)setItems:(NSMutableArray *)items
{
    
    _items = items;
    self.pageControl.numberOfPages = items.count / 8 + 1;//加多一页
    self.scrollView.contentSize = CGSizeMake(ScreenWid * (items.count / 8 + 1), _scrollView.frameHeight);
    
    float w = self.frameWidth * 20 / 21 / 4 * 0.8;
    float space = w / 4;
    float h = (self.frameHeight - 20 - space * 2) / 2;
    
    float x = space, y = space;
    int i = 0, page = 0;
    for (ZXChatBoxItemView * item in _items) {
        
        [self.scrollView addSubview:item];
        [item setFrame:CGRectMake(x, y, w, h)];
        [item setTag:i];
        [item addTarget:self action:@selector(didSelectedItem:) forControlEvents:UIControlEventTouchUpInside];
        i ++;
        page = i % 8 == 0 ? page + 1 : page;
        x = (i % 4 ? x + w : page * self.frameWidth) + space;
        y = (i % 8 < 4 ? space : h + space * 1.5);
    }
}


-(void)setUI{
    
    //    self.photobutton.backgroundColor = [UIColor redColor];
    //
    //    self.takepicturebutton.backgroundColor = [UIColor yellowColor];
    //
    //    self.callbutton.backgroundColor = [UIColor orangeColor];
    //
    
}

-(UIButton*)photobutton{
    
    if (!_photobutton) {
        
        _photobutton = [[UIButton alloc]init];
        
        [_photobutton addTarget:self action:@selector(photo) forControlEvents:UIControlEventTouchUpInside];
        
        [_photobutton.layer setMasksToBounds:YES];
        [_photobutton.layer setCornerRadius:10.0f];
        [_photobutton.layer setBorderWidth:0.5f];
        [_photobutton.layer setBorderColor: [UIColor colorWithHexString:@"#dadada"].CGColor];
        
    }
    
    
    return _photobutton;
    
}

-(UIButton*)takepicturebutton{
    
    if (!_takepicturebutton) {
        
        _takepicturebutton = [[UIButton alloc]init];
        
        [_takepicturebutton addTarget:self action:@selector(takepicture) forControlEvents:UIControlEventTouchUpInside];
        
        [_takepicturebutton.layer setMasksToBounds:YES];
        [_takepicturebutton.layer setCornerRadius:10.0f];
        [_takepicturebutton.layer setBorderWidth:0.5f];
        [_takepicturebutton.layer setBorderColor: [UIColor colorWithHexString:@"#dadada"].CGColor];
    }
    
    
    return _takepicturebutton;
    
}

-(UIButton*)filebutton{
    
    if (!_filebutton) {
        
        _filebutton = [[UIButton alloc]init];
        
        [_filebutton addTarget:self action:@selector(sendfile) forControlEvents:UIControlEventTouchUpInside];
        
        [_filebutton.layer setMasksToBounds:YES];
        [_filebutton.layer setCornerRadius:10.0f];
        [_filebutton.layer setBorderWidth:0.5f];
        [_filebutton.layer setBorderColor: [UIColor colorWithHexString:@"#dadada"].CGColor];
    }
    
    
    return _filebutton;
    
}
-(UIButton*)callbutton{
    
    if (!_callbutton) {
        
        _callbutton = [[UIButton alloc]init];
        
        [_callbutton addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
        [_callbutton.layer setMasksToBounds:YES];
        [_callbutton.layer setCornerRadius:10.0f];
        [_callbutton.layer setBorderWidth:0.5f];
        [_callbutton.layer setBorderColor: [UIColor colorWithHexString:@"#dadada"].CGColor];
    }
    
    
    return _callbutton;
    
}


-(UIButton*)callVideobutton{
    
    if (!_callVideobutton) {
        
        _callVideobutton = [[UIButton alloc]init];
        
        [_callVideobutton addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
        [_callVideobutton.layer setMasksToBounds:YES];
        [_callVideobutton.layer setCornerRadius:10.0f];
        [_callVideobutton.layer setBorderWidth:0.5f];
        [_callVideobutton.layer setBorderColor: [UIColor colorWithHexString:@"#dadada"].CGColor];
    }
    
    
    return _callVideobutton;
    
}


-(UILabel*)photobuttonLabel
{
    
    if (!_photobuttonLabel) {
        
        _photobuttonLabel = [[UILabel alloc]init];
        
        _photobuttonLabel.textAlignment = NSTextAlignmentCenter;
        _photobuttonLabel.textColor = RGB(106, 106, 106);
        _photobuttonLabel.font = [UIFont systemFontOfSize:13];
        
        _photobuttonLabel.text = NSLocalizedString(@"Album", @"Album");
        
        
    }
    
    return _photobuttonLabel;
    
}


-(UILabel*)takepicturebuttonLabel
{
    
    if (!_takepicturebuttonLabel) {
        
        _takepicturebuttonLabel = [[UILabel alloc]init];
        
        _takepicturebuttonLabel.textAlignment = NSTextAlignmentCenter;
        _takepicturebuttonLabel.textColor = RGB(106, 106, 106);
        _takepicturebuttonLabel.font = [UIFont systemFontOfSize:13];
        
        _takepicturebuttonLabel.text = NSLocalizedString(@"Camera", @"Camera");
    }
    
    return _takepicturebuttonLabel;
    
}


-(UILabel*)callbuttonLabel
{
    
    if (!_callbuttonLabel) {
        
        _callbuttonLabel = [[UILabel alloc]init];
        _callbuttonLabel.textAlignment = NSTextAlignmentCenter;
        _callbuttonLabel.textColor = RGB(106, 106, 106);
        _callbuttonLabel.font = [UIFont systemFontOfSize:13];
        
        _callbuttonLabel.text = NSLocalizedString(@"Audio Call", @"Audio Call");
    }
    
    return _callbuttonLabel;
    
}

-(UILabel*)callVideobuttonLabel
{
    
    if (!_callVideobuttonLabel) {
        
        _callVideobuttonLabel = [[UILabel alloc]init];
        
        _callVideobuttonLabel.textAlignment = NSTextAlignmentCenter;
        _callVideobuttonLabel.textColor = RGB(106, 106, 106);
        _callVideobuttonLabel.font = [UIFont systemFontOfSize:13];
        
        _callVideobuttonLabel.text = NSLocalizedString(@"Video Call", @"Video Call");
        
    }
    
    return _callVideobuttonLabel;
    
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    UIColor* inputbkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColorLight"];
        inputbkColor = [UIColor colorNamed:@"inputViewBkColor"];
    }
    else{
        bkColor = [UIColor lightGrayColor];
        inputbkColor = [UIColor colorWithHexString:@"#e4e3e3"];
    }
    
    self.backgroundColor = inputbkColor;
}

-(UILabel*)filebuttonLabel
{
    
    if (!_filebuttonLabel) {
        
        _filebuttonLabel = [[UILabel alloc]init];
        
        _filebuttonLabel.textAlignment = NSTextAlignmentCenter;
        _filebuttonLabel.textColor = RGB(106, 106, 106);
        _filebuttonLabel.font = [UIFont systemFontOfSize:13];
        
        _filebuttonLabel.text = NSLocalizedString(@"File Transfer", @"File");
        
    }
    
    return _filebuttonLabel;
    
}



- (UIView *)separatedLine
{
    if (!_separatedLine) {
        _separatedLine = [[UIView alloc]init];
        _separatedLine.backgroundColor = [UIColor colorWithHexString:@"#dadada"];
    }
    return _separatedLine;
}

-(UIImageView*)photobuttonImage{
    
    
    if (!_photobuttonImage) {
        
        _photobuttonImage = [[UIImageView alloc]init];
        
        [_photobuttonImage setImage:[UIImage imageNamed:@"message_botm_add_pic_ico"]];
        
    }
    
    return _photobuttonImage;
    
    
}


-(UIImageView*)takepicturebuttonImage{
    
    
    if (!_takepicturebuttonImage) {
        
        _takepicturebuttonImage = [[UIImageView alloc]init];
        
        [_takepicturebuttonImage setImage:[UIImage imageNamed:@"message_botm_add_camera_ico"]];
        
    }
    
    return _takepicturebuttonImage;
    
    
}


-(UIImageView*)callbuttonImage{
    
    
    if (!_callbuttonImage) {
        
        _callbuttonImage = [[UIImageView alloc]init];
        
        [_callbuttonImage setImage:[UIImage imageNamed:@"message_botm_add_audio_ico"]];
        
    }
    
    return _callbuttonImage;
    
    
}


-(UIImageView*)callVideobuttonImage{
    
    
    if (!_callVideobuttonImage) {
        
        _callVideobuttonImage = [[UIImageView alloc]init];
        
        [_callVideobuttonImage setImage:[UIImage imageNamed:@"message_botm_add_video_ico"]];
        
    }
    
    return _callVideobuttonImage;
    
}

-(UIImageView*)filebuttonImage{
    
    
    if (!_filebuttonImage) {
        
        _filebuttonImage = [[UIImageView alloc]init];
        
        [_filebuttonImage setImage:[UIImage imageNamed:@"message_send_file_message_ico"]];
        
    }
    
    return _filebuttonImage;
    
}



#pragma mark -
#pragma mark button Target

-(void)photo{
    
    NSLog(@"photo");
    
    if (self.delegate) {
        
        //   [self.delegate testdelete:@"test"];
        
        
        [self.delegate sendImage];
        
        
    }
    
    
}

-(void)takepicture{
    
    NSLog(@"takepicture");
    
    
    if (self.delegate) {
        
        
        
        [self.delegate sendCustomCamera];
        
        
    }
    
}

-(void)sendfile{
    
    NSLog(@"takepicture");
    
    
    if (self.delegate) {
        
        
        
        [self.delegate sendFile];
        
        
    }
    
}

-(void)call:(UIButton*)sender{
    
    
    
    if (sender == _callbutton) {
        
        if (self.delegate) {
            
            NSLog(@"call");
            
            [self.delegate makeCall:NO];
            
        }
        
    }else if (sender == _callVideobutton){
        
        NSLog(@"call video");
        
        
        [self.delegate makeCall:YES];
        
        
    }
    
    
    
    
    
}


@end
