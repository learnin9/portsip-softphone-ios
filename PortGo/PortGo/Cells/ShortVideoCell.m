//
//  ShortVideoCell.m
//  PortSIP
//
//  Created by 今言网络 on 2018/8/27.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import "ShortVideoCell.h"
#import "UIColor_Hex.h"
#import "Masonry.h"
//#import <SDWebImage/UIImageView+WebCache.h>

#import "HSChatViewController.h"
#import "ZFJVoiceBubble.h"
#import "UIColor_Hex.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DataBaseManage.h"
@interface ShortVideoCell ()<ZFJVoiceBubbleDelegate>
{
    UILabel * label;
}

@end
@implementation ShortVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        NSLog(@"cellimage init");
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}


//视频
-(void)setCellImage:(UIImage*)cellimage andTYPE:(NSString* )type{
    
    cellimageview = [[UIImageView alloc]init];
    _messageTYPE  = type;
  
    UITapGestureRecognizer * imagetap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showimage)];
    [cellimageview addGestureRecognizer:imagetap];
    
    UIImage * shuiyingimage = [UIImage imageNamed:@"record_play_ico@3x"];
 
    CGRect  logerect = CGRectMake(0, 0, 80, 130);
    CGRect  ImageRect = CGRectMake(20, 45, 40, 40);
    
    UIImage * newimage  = [self addWatemarkImageWithLogoImage:cellimage watemarkImage:shuiyingimage logoImageRect:logerect watemarkImageRect:ImageRect];
    
    cellimageview.image = newimage;
    
    if (IS_EVENT_INCOMING(self.chatMessage.status)){
        
        cellimageview.frame = CGRectMake(50, 10, 80, 130);
    }else
    {
        cellimageview.frame = CGRectMake(ScreenWid -100, 10, 80, 130);
    }
    
    cellimageview.layer.cornerRadius = self->cellimageview.frame.size.width*0.1;
    cellimageview.layer.masksToBounds = YES;
    
    [self.contentView addSubview:cellimageview];
    
    //   [self bringSubviewToFront:cellimageview];
    cellimageview .userInteractionEnabled = YES;
}

//音视频，图片，点击回调
-(void)showimage{
    if([_messageTYPE hasPrefix:@"video"] || [_messageTYPE isEqualToString:@".MP4"]) {
        if (_shortVideoBlock) {
            self.shortVideoBlock();
        }
    }
    else if([_messageTYPE hasPrefix:@"image"])
    {
        if (_imageBlock) {
            self.imageBlock(cellimageview);
        }
    }
    
    else if([_messageTYPE hasPrefix:@"audio"])
    {
        if (_RecordBlock) {
            self.RecordBlock();
            //音频消息 ，点击后，标志为已读
            _chatMessage.msgRead = TRUE;
        }
    }
    
    return;
}


- (void)setStatusIcon:(int)messageStatus{
    if(IS_EVENT_INCOMING(messageStatus)){
        if(IS_EVENT_ATTACHFAILED(messageStatus)||IS_EVENT_FAILED(messageStatus)){
            
        }else if(IS_EVENT_PROCESSING(messageStatus)){
            
        }
    }else{
        if(IS_EVENT_ATTACHFAILED(messageStatus)||IS_EVENT_FAILED(messageStatus)){
            
        }else if(IS_EVENT_PROCESSING(messageStatus)){
            
        }
    }
    
}

- (UIImage *)addWatemarkImageWithLogoImage:(UIImage *)logoImage watemarkImage:(UIImage *)watemarkImage logoImageRect:(CGRect)logoImageRect watemarkImageRect:(CGRect)watemarkImageRect{
    
    // 创建一个graphics context来画我们的东西
    UIGraphicsBeginImageContext(logoImageRect.size);
    
    // graphics context就像一张能让我们画上任何东西的纸。我们要做的第一件事就是把person画上去
    [logoImage drawInRect:CGRectMake(0, 0, logoImageRect.size.width, logoImageRect.size.height)];
    
    // 然后在把hat画在合适的位置
    [watemarkImage drawInRect:CGRectMake(watemarkImageRect.origin.x, watemarkImageRect.origin.y, watemarkImageRect.size.width, watemarkImageRect.size.height)];
    
    // 通过下面的语句创建新UIImage
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 最后，我们必须得清理并关闭这个再也不需要的context
    UIGraphicsEndImageContext();
    return newImage;
    
}

//图片
-(void)setCellImage2:(NSURL*)cellimageurl andTYPE:(NSString* )type{
    
    cellimageview = [[UIImageView alloc]init];
    
    _messageTYPE  = type;
    
    UITapGestureRecognizer * imagetap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showimage)];
    
    [cellimageview addGestureRecognizer:imagetap];
    
    UIImage * img =[UIImage imageWithContentsOfFile:cellimageurl.path];
    if(img==NULL){
        img =[UIImage imageNamed:@"pic_failed"];
    }
    
    self->_tupianimg = img;
    [self->cellimageview setImage:self->_tupianimg];

    CGFloat fixelW = CGImageGetWidth(self->_tupianimg.CGImage);
    CGFloat fixelH = CGImageGetHeight(self->_tupianimg.CGImage);
    
    float with = 80,heigt = 130;
    
    if (fixelW >80) {
        with = 80;
        heigt = fixelH *80 /fixelW;
    }
    
    self->statusview = [[UIImageView alloc]init];
    if (IS_EVENT_INCOMING(self.chatMessage.status)){
        self->cellimageview.frame = CGRectMake(50, 10, with, heigt);
        self->statusview.frame = CGRectMake(50+with+5, 10+heigt/2, 20, 20);//50 ==touxiang
    }else
    {
        self->cellimageview.frame = CGRectMake(ScreenWid -100, 10, with, heigt);
        self->statusview.frame = CGRectMake(ScreenWid-with-20 -20-5, 0+heigt/2, 20, 20);
    }
    
    if(IS_EVENT_PROCESSING(_chatMessage.status)){
        self->statusview.hidden = NO;
        statusview.image = [UIImage imageNamed:@"mss_browseLoading@2x"];//此处应该是进度条动画提示
    }else if(IS_EVENT_ATTACHFAILED(_chatMessage.status)||IS_EVENT_FAILED(_chatMessage.status)){
        self->statusview.hidden = NO;
        statusview.image = [UIImage imageNamed:@"Sending_failed_ico"];
    }else{
        self->statusview.hidden = YES;
    }
    
    cellimageview.layer.cornerRadius = self->cellimageview.frame.size.width*0.1;
    cellimageview.layer.masksToBounds = YES;

    
    [self.contentView addSubview:cellimageview];
    [self.contentView addSubview:statusview];
    if([self.messageTYPE hasPrefix:@"video"]){//给视频添加一个播放按钮
        
        UIImageView* playImageview = [[UIImageView alloc]init];
        UIImage* playImage = [UIImage imageNamed:@"record_play_ico@2x"];
        [playImageview setImage:playImage];
        [playImageview sizeToFit];
        playImageview.center = [cellimageview convertPoint:cellimageview.center fromView:cellimageview.superview];
        
        [cellimageview addSubview:playImageview];
    }
    //
    
    cellimageview .userInteractionEnabled = YES;
}


-(void)setlengthLab:(int)length{
    
    label.text = [NSString stringWithFormat:@"%d''",length];
    
    label.font = [UIFont  systemFontOfSize:13];
    
    if (_isListen) {
        label.textColor  =[UIColor grayColor];
    }else
    {
        label.textColor  =[UIColor darkTextColor];
    }
}

//音频
-(void)setCellImage3:(NSURL*)cellRecordurl andTYPE:(NSString* )type{
    
    cellimageview3 = [[UIImageView alloc]init];
    _messageTYPE  = type;
    
    UITapGestureRecognizer * imagetap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showimage)];
    
    [cellimageview3 addGestureRecognizer:imagetap];
    
    NSLog(@"set record cell");

    CGRect  logerect = CGRectMake(0, 0, 80, 130);
    CGRect  ImageRect = CGRectMake(20, 45, 40, 40);

    cellimageview3.layer.cornerRadius = 10.0;//2.0是圆角的弧度，根据需求自己更改
    UIImageView * xiaotubiaoimageview = [[UIImageView alloc]init];
    
    label = [[UILabel alloc]init];
    NSArray *animationImages;
    UIImage *image0, *image1, *image2;//
    int with = 50;
    //
    with += (_chatMessage.msglen*150/30);//30最长录制时间。最大宽度 200
    self->statusview = [[UIImageView alloc]init];
    
    if (IS_EVENT_INCOMING(self.chatMessage.status)){
        image0 = [UIImage imageNamed:@"voicer"];
        image1 = [UIImage imageNamed:@"voicer1"];
        image2 = [UIImage imageNamed:@"voicer2"];
        animationImages = @[[UIImage imageNamed:@"voicer"], [UIImage imageNamed:@"voicer1"], [UIImage imageNamed:@"voicer2"]];
        
        cellimageview3.frame = CGRectMake(45, 8, with, 35);
        xiaotubiaoimageview.frame = CGRectMake(5, 8, 20, 20);
        label.frame = CGRectMake(45+20+5+5, 12, 30, 30);//头像+喇叭+5
        cellimageview3.backgroundColor = [UIColor colorWithHexString:@"#edf9fe"];
        
        self->statusview.frame = CGRectMake(45 +with+3, 15, 20, 20);//头像宽+音频条+5gap
    }else
    {
        image0 = [UIImage imageNamed:@"voicel"];
        image1 = [UIImage imageNamed:@"voicel1"];
        image2 = [UIImage imageNamed:@"voicel2"];
        animationImages = @[[UIImage imageNamed:@"voicel"], [UIImage imageNamed:@"voicel1"], [UIImage imageNamed:@"voicel2"]];
        
        cellimageview3.frame = CGRectMake(ScreenWid -with-20, 8, with, 35);
        xiaotubiaoimageview.frame = CGRectMake(with-20, 8, 20, 20);
        label.frame = CGRectMake(ScreenWid -20-20 -30, 12, 30, 30);
        label.textAlignment= NSTextAlignmentRight;
        cellimageview3.backgroundColor = [UIColor colorWithHexString:@"#f7f7f7"];
        self->statusview.frame = CGRectMake(ScreenWid -with-20-3-20, 15, 20, 20);//屏幕款-with（音频条宽）-（20）右边距-5-20（自身宽）
    }
    
    if(IS_EVENT_PROCESSING(_chatMessage.status)){
        self->statusview.hidden = NO;
        statusview.image = [UIImage imageNamed:@"mss_browseLoading@2x"];//此处应该是进度条动画提示
    }else if(IS_EVENT_ATTACHFAILED(_chatMessage.status)||IS_EVENT_FAILED(_chatMessage.status)){
        self->statusview.hidden = NO;
        statusview.image = [UIImage imageNamed:@"Sending_failed_ico"];
    }else{
        if (IS_EVENT_INCOMING(self.chatMessage.status)&&!(self.chatMessage.msgRead)){//接收到，未读标记
            statusview.image = [UIImage imageNamed:@"audio_unread"];
            self->statusview.hidden = NO;
        }else{
            self->statusview.hidden = YES;
        }
    }
    [xiaotubiaoimageview setImage:image2];
    xiaotubiaoimageview.animationImages = animationImages;
    xiaotubiaoimageview.animationDuration = animationImages.count/3;//一次循环的持续时间，默认30fps count/30
//    xiaotubiaoimageview.animationRepeatCount = 1;//重复次数，默认==0无限循环
    
    //statusview.image = [UIImage imageNamed:@"Sending_failed_ico"];
    [self.contentView addSubview:cellimageview3];
    [self.contentView addSubview:statusview];
    cellimageview3 .userInteractionEnabled = YES;
    [self bringSubviewToFront:cellimageview3];
#if true
    [cellimageview3 addSubview:xiaotubiaoimageview];
    [self setlengthLab:_chatMessage.msglen];
    [self.contentView addSubview:label];
    
#else
    if (IS_EVENT_INCOMING(self.chatMessage.status)){
        //cellimageview3.frame = CGRectMake(50, 10, 150, 30);
        ZFJVoiceBubble *voiceMegBtn = [[ZFJVoiceBubble alloc]init];
        voiceMegBtn.contentURL = cellRecordurl;//[NSURL URLWithString:@"http://7xszyu.com1.z0.glb.clouddn.com/media_blog_9250_1488873184.mp3"];
        voiceMegBtn.frame = CGRectMake(50, 10, 150, 30);
        voiceMegBtn.delegate = self;         //设置代理
        voiceMegBtn.isHaveBar = YES;         //当前页面是否有UINavigationBar
        voiceMegBtn.userName = @"墨小北";     //用户名
        [self.contentView addSubview:voiceMegBtn];

    }else
    {
        ZFJVoiceBubble *voiceMegBtn1 = [[ZFJVoiceBubble alloc]init];
        voiceMegBtn1.contentURL = cellRecordurl;//[NSURL URLWithString:@"http://7xszyu.com1.z0.glb.clouddn.com/media_blog_9250_1488873184.mp3"];
        voiceMegBtn1.frame = CGRectMake(ScreenWid -180, 10, 150, 30);
        voiceMegBtn1.delegate = self;         //设置代理
        voiceMegBtn1.isHaveBar = YES;         //当前页面是否有UINavigationBar
        voiceMegBtn1.userName = @"墨小北";     //用户名
        voiceMegBtn1.invert = YES;            //是否反转
        [self.contentView addSubview:voiceMegBtn1];
        [self.contentView addSubview:label];
    }

#endif
    
}

#pragma mark - ZFJVoiceBubbleDelegate
- (void)voiceBubbleDidStartPlaying:(ZFJVoiceBubble *)voiceBubble{
    NSLog(@"aaaaaaaa");
}

// YES 开始播放  NO 停止播放
- (void)voiceBubbleStratOrStop:(BOOL)isStart{
    if(isStart){
        NSLog(@"开始播放");
    }else{
        NSLog(@"停止播放");
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"register  proccess=%p",self);
    NSString* obKey =@"playID";
    if ([keyPath isEqualToString:obKey]&&[object isKindOfClass:HSChatViewController.class]){
        NSInteger value = [[object valueForKey:obKey] intValue];
        NSString* messageType = [self.chatMessage.jsonContent valueForKey:KEY_MESSAGE_TYPE];
        if([MESSAGE_TYPE_AUDIO isEqualToString:messageType]) {
            UIImageView* view = cellimageview3.subviews[0];
            if(self.chatMessage.historyId == value){
                if(IS_EVENT_INCOMING_SUCESS(self.chatMessage.status)){//
                    self.chatMessage.msgRead = true;
                    statusview.hidden =TRUE;
                }
                [view startAnimating];
            }else{
                [view stopAnimating];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//指定宽度按比例缩放
-(UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}


-(void)loadContactIconWhichside:(int)side {
    
    if (side == 0) { // 信息页面右边自己的图标不展示
        self.contactIcon.hidden = YES;
        self.textImage.hidden = YES;
        return ;
    }
    
    if (self.iocn) {
        self.contactIcon.hidden = NO;
        self.textImage.hidden = YES;
        if (!self.contactIcon) {
            
            CGRect temp = CGRectMake(10, 5, 36, 36);
            
            if(ifnosingle){
                
                temp = CGRectMake(10, 15+5, 36, 36);
            }
            
            
            self.contactIcon = [[UIImageView alloc] initWithFrame:temp];
            
            
            
            self.contactIcon.layer.cornerRadius = 15.0;
            self.contactIcon.clipsToBounds = YES;
            self.contactIcon.image = self.iocn;
            
            NSLog(@"self.iocn=====%@",self.iocn);
            
            [self.contentView addSubview:self.contactIcon];
            
            
            [self.contactIcon setFrame:CGRectMake(5, 10, 34, 34)];
        }
        
        self.contactIcon.image = self.iocn;
        
    } else {
        self.contactIcon.hidden = YES;
        self.textImage.hidden = NO;
        
        if (!_textImage) {
            
            CGRect temp2 = CGRectMake(10, 2, 34, 34);
            
            if(ifnosingle){
                
                temp2 = CGRectMake(10, 15+2, 34, 34);
                
            }
            
            _textImage = [[TextImageView alloc] initWithFrame:temp2];
            _textImage.textImageLabel.font = [UIFont fontWithName:@"Arial" size:15];
            _textImage.raduis = 17.0;
            _textImage.layer.cornerRadius = _textImage.bounds.size.width / 2;
            _textImage.clipsToBounds = YES;
            [self.contentView addSubview:_textImage];
            
            [_textImage setFrame:CGRectMake(5, 10, 34, 34)];

        }

        
        //     NSDictionary *dic = [contactView numbers2ContactsMapper]; //FIXIT
        //    Contact *contact_ = [dic objectForKey:_chatMessage.nickName];
        
        Contact *contact_ = _mycontact;
        
        
        NSString *display = nil;
        if (contact_) {
            display = contact_.displayName;
        } else {
            display = _chatMessage.nickName;
            
        }
        if(display.length<2){
            display = @" ";
        }
        NSLog(@"display======%@",display);
        
        if ([self includeChinese:display]) {
            NSString* sub = [display substringToIndex:1];
            if ([self includeChinese:sub]) {
                _textImage.textImageLabel.text = [display substringToIndex:1];
            } else {
                _textImage.textImageLabel.text = [display substringToIndex:2];
            }
        } else {
            if ([display containsString:@" "]) {
                NSArray *strs = [display componentsSeparatedByString:@" "];
                NSString *first = strs[0];
                NSString *last = strs[1];
                
                
                if (first.length<1) {
                    first =@" ";
                }
                
                if (last.length <1) {
                    last = @" ";
                }
                
                _textImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],[last substringToIndex:1]];
            } else {
                _textImage.textImageLabel.text = [display substringToIndex:2];
            }
        }
    }

}

- (BOOL)includeChinese:(NSString *)predicateStr
{
    for(int i=0; i< [predicateStr length];i++)
    {
        int a =[predicateStr characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

@end
