//
//  ChatViewCell.m
//  PortGo
//
//  Created by 今言网络 on 2017/6/27.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "ChatViewCell.h"
#import "HSChatMessage.h"
#import "AppDelegate.h"

#import "Masonry.h"
#import "UIColor_Hex.h"

#import "PPStickerInputView.h"

#import "MSSBrowseDefine.h"
#import "UIImageView+WebCache.h"
#import "UIImage+PKShortVideoPlayer.h"
#import "HttpHelper.h"

@implementation ChatViewCell 
static const int bubbleTBGap = 8;
static const int bubbleLRGap = 15;
static const int cellMargin = 5;
const int HEAD_AVARTA_HEIGHT = 34;
const int VOICE_ICON_HEIGHT = 25;
const int BUBBLE_CORNER = 10;
const int IMG_CORNER = 5;
const int STATUS_MARGIN = 5;
const int TEXT_SIZE = 18;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //        NSArray *nibView =  [[NSBundle mainBundle] loadNibNamed:@"ChatViewCell" owner:self options:nil];
        //        self = [nibView objectAtIndex:0];
        //        self.frame = frame;
        //        [self addSubview:backView];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor *bubleColor,*bubleLocalColor;
    if (@available(iOS 11.0, *)) {
        bubleColor = [UIColor colorNamed:@"bubbleBkColor"];
        bubleLocalColor = [UIColor colorNamed:@"bubbleLocalBKColor"];
    }
    else{
        bubleColor = [UIColor colorWithHexString:@"0xedf0f0"];
    }
    
    if (IS_EVENT_OUTGOING(self.messageStatus)) {//发送出去的消息
       const CGFloat *components = CGColorGetComponents(bubleColor.CGColor);
       self.chatBuble.backgroundColor = bubleLocalColor;
    }else{//接收的消息
       self.chatBuble.backgroundColor = bubleColor;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        NSArray *nibView =  [[NSBundle mainBundle] loadNibNamed:@"ChatView" owner:self options:nil];
        chatViewCell =[nibView objectAtIndex:0];
        chatViewCell.frame = self.frame;
        
        [self.contentView addSubview:chatViewCell];
        if(reuseIdentifier!=NULL)
        {
            if([reuseIdentifier isEqualToString:CHATVIEW_TYPE_TEXT]){
                chatContent = [UIView new];
                //chatContent.contentMode=UIViewContentModeCenter;
                UILabel* lable = [UILabel new];
                lable.font = [UIFont systemFontOfSize:TEXT_SIZE];
                lable.textAlignment = NSTextAlignmentNatural;
                lable.textColor =[UIColor blackColor];
                [chatContent addSubview:lable];
                
            }else if([reuseIdentifier isEqualToString:CHATVIEW_TYPE_FILE]){
                chatContent = [UIView new];
                UILabel* viewfileName = [UILabel new];
                viewfileName.font = [UIFont systemFontOfSize:18];
                
                UILabel* viewfileDesc = [UILabel new];
                viewfileDesc.font = [UIFont systemFontOfSize:14];
                viewfileDesc.textColor = [UIColor grayColor];
                
                UIImageView* viewfielIcon = [UIImageView new];
                viewfielIcon.contentMode = UIViewContentModeScaleAspectFit;
                
                [chatContent addSubview:viewfileName];
                [chatContent addSubview:viewfileDesc];
                [chatContent addSubview:viewfielIcon];
            }else if([reuseIdentifier isEqualToString:CHATVIEW_TYPE_VIDEO]){
                chatContent = [[UIImageView alloc]init];
                UIImageView* imageView = [[UIImageView alloc]init];
                UIImageView* player = [[UIImageView alloc]init];
                //圆角
                imageView.layer.cornerRadius = IMG_CORNER;//chatContent.frame.size.width*0.1;
                imageView.layer.masksToBounds = YES;
                
                [chatContent addSubview:imageView];
                [chatContent addSubview:player];
                
            }else if([reuseIdentifier isEqualToString:CHATVIEW_TYPE_AUDIO]){
                chatContent = [UIView new];
                
                UIImageView* viewPlayer = [[UIImageView alloc]init];
                UILabel* label = [[UILabel alloc]init];
                label.font = [UIFont  systemFontOfSize:13];
                label.textAlignment=NSTextAlignmentLeft;
                [chatContent addSubview:viewPlayer];
                [chatContent addSubview:label];//2"
                
            }else if([reuseIdentifier isEqualToString:CHATVIEW_TYPE_IMAGE]){
                chatContent = [UIView new];
                UIImageView* imageView = [[UIImageView alloc]init];
                //圆角
                imageView.layer.cornerRadius = IMG_CORNER;//chatContent.frame.size.width*0.1;
                imageView.layer.masksToBounds = YES;
                
                [chatContent addSubview:imageView];
            }
        }
        if(chatContent==nil){
            chatContent = [UILabel new];
        }
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        chatViewCell.backgroundColor = [UIColor clearColor];
        
        [self.chatBuble addSubview:chatContent];
        
        UILongPressGestureRecognizer *longTapMessage = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longClickMessage)];
        UITapGestureRecognizer * tapMessage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickMessage)];
        
        chatContent.userInteractionEnabled = YES;
        [chatContent addGestureRecognizer:tapMessage];
        
        chatContent.userInteractionEnabled = YES;
        [chatContent addGestureRecognizer:longTapMessage];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

+(int)BUBBLE_GAP{
    return bubbleTBGap;
}

+(int)CELL_MARGIN{
    return cellMargin;
}


+ (int)getCellHeight:(HSChatMessage*)msg{
    //int left=bubbleLRGap,top =bubbleTBGap;
    float contentWidth,contentHeight;
    CGSize size = CGSizeMake(MAIN_SCREEN_WIDTH - 110,3000); //设置一个行高上限
    if(msg!=nil||msg.jsonContent!=nil){
        NSString* msgType = [msg.jsonContent valueForKey:KEY_MESSAGE_TYPE];

       if([MESSAGE_TYPE_FILE isEqualToString:msgType]){
            CGFloat maxContentW = MAIN_SCREEN_WIDTH - 160;
            int fileIconWith =40, fileIconHeight=40,gap = 5;
            int filenameWidth =maxContentW -fileIconWith-gap,filenameHeight=[UIFont systemFontOfSize:TEXT_SIZE].lineHeight;
            int fileDescWith =filenameWidth,fileDescHeight =[UIFont systemFontOfSize:14].lineHeight;
           
            msg.contentRect = CGRectMake(0, 0, filenameWidth+gap+fileIconWith,filenameHeight+gap+fileDescHeight+bubbleTBGap*2);
            
        }else if([MESSAGE_TYPE_VIDEO isEqualToString:msgType]||[MESSAGE_TYPE_IMAGE isEqualToString:msgType]){
//            left = 0;top=0;
            UIImage* img = [msg getImage];
            int fixelW = (int)CGImageGetWidth(img.CGImage);
            int fixelH = (int)CGImageGetHeight(img.CGImage);
            
            float width = 80,height = 130;
            
            if (fixelW >80) {
                width = 80;
                height = fixelH *80 /fixelW;
            }
            msg.contentRect = CGRectMake(0, 0, width,height);
            
        }else if([MESSAGE_TYPE_AUDIO isEqualToString:msgType]){
            contentWidth = 50;
            contentWidth += (msg.msglen*150/30);//30最长录制时间。最大宽度 200
            contentHeight = [UIFont systemFontOfSize:TEXT_SIZE].lineHeight;//应该与单行文本的高度一致，这样比较好
            msg.contentRect = CGRectMake(0, 0, contentWidth+bubbleLRGap*2,contentHeight+bubbleTBGap*2);
        }else{
            NSString* content = [msg.jsonContent valueForKey:KEY_TEXT_CONTENT];
            content= ((content==nil||msgType==nil)?NSLocalizedString(@"UnknowFormat_UnknowFormat", @"UnknowFormat_UnknowFormat"):content);
            NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
            
            NSMutableString * tempstr = [[NSMutableString alloc]initWithString: content];
            
            NSString *regex = @"\\[[^\\]]*\\]";
            NSError *error;
            NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                     options:NSRegularExpressionCaseInsensitive
                                                                                       error:&error];
            // 对str字符串进行匹配
            NSArray *matches = [regular matchesInString:tempstr
                                                options:0
                                                  range:NSMakeRange(0, tempstr.length)];
            
            NSMutableArray*  result = [[NSMutableArray alloc]init];
            
            // 遍历匹配后的每一条记录
            for (NSTextCheckingResult *match in matches) {
                NSRange range = [match range];
                NSString *mStr = [tempstr substringWithRange:range];
                [result addObject:mStr];
                
            }
            NSString* newstr = content;
            //1000 110
            //   NSLog(@"newstr.length===%d",newstr.length);
#if 0
            NSString *targetStr = @"1000";
            
            if (newstr.length<100) {
                targetStr = @"110";
            }
            
            for (NSString *regStr in result) {
                newstr = [newstr stringByReplacingOccurrencesOfString:regStr withString:targetStr];
            }
#endif
            CGSize labelSize = [newstr boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
            CGFloat maxContentW = MAIN_SCREEN_WIDTH - 110;
            CGRect frame = CGRectMake(0, 0, labelSize.width > maxContentW ? maxContentW+bubbleLRGap*2 : labelSize.width+bubbleLRGap*2, labelSize.height + bubbleTBGap*2);
            
            msg.contentRect = frame;
        }
    }

    
    //msg.contentRect.size.height = msg.contentRect.size.height<HEAD_AVARTA_HEIGHT?HEAD_AVARTA_HEIGHT:msg.contentRect.size.height;
    
    return msg.contentRect.size.height+cellMargin*2;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self resizeContentView:self.chatMessage];
    int cellHeight;
    CGRect frame;
    if(chatContent!=nil){
        frame = chatContent.frame;
    }else{
        frame =CGRectMake(1, 1, 10, 10);
    }
    
    NSString* msgType = [self.chatMessage.jsonContent valueForKey:KEY_MESSAGE_TYPE];
    CGRect bubbleRect = self.chatBuble.frame;
    
    //计算气泡宽高
    if([MESSAGE_TYPE_VIDEO isEqualToString:msgType]||[MESSAGE_TYPE_IMAGE isEqualToString:msgType]){
        self.chatBuble.backgroundColor = [UIColor clearColor];
        bubbleRect.size.height = frame.size.height;//音视频，气泡背景为空
        bubbleRect.size.width =  frame.size.width;
        
        bubbleRect.origin.y = cellMargin;
        self.chatBuble.frame = bubbleRect;
    }else{
        bubbleRect.size.height = frame.size.height;
        bubbleRect.size.width = frame.size.width;
        
//        if (ifnosingle) {
//            bubbleRect.origin.y = cellMargin +bubbleTBGap;
//        }
//        else{
            bubbleRect.origin.y = cellMargin;
//        }
        self.chatBuble.frame = bubbleRect;
    }
    UIColor *bubleLocalColor,*bubleColor;
   if (@available(iOS 11.0, *)) {
        bubleColor = [UIColor colorNamed:@"bubbleBkColor"];
        bubleLocalColor = [UIColor colorNamed:@"bubbleLocalBKColor"];
    }
    else{
        bubleColor =  [UIColor colorWithHexString:@"#edf9fe"];
        bubleLocalColor = [UIColor colorWithHexString:@"#f0f0f0"];
    }
    //计算气泡的x
    if (IS_EVENT_OUTGOING(self.messageStatus)) {//发送出去的消息
        if (_chatMessage.isFirstRow) { //是每一个section的第一行
            [self loadContactIconWhichside:0];
        }
        
        const CGFloat *components = CGColorGetComponents(bubleColor.CGColor);
        self.chatBuble.backgroundColor = [UIColor colorWithRed:components[0]+0.02 green:components[1]+0.02 blue:components[2]+0.02 alpha:1.0];
        
        bubbleRect.origin.x = MAIN_SCREEN_WIDTH - bubbleRect.size.width - 15;//15=tableview 右边页边距
        
        self.chatBuble.frame = bubbleRect;
    }else{//接收的消息
        if (_chatMessage.isFirstRow) {
            [self loadContactIconWhichside:1];
        }
        
        self.chatBuble.backgroundColor = bubleColor;
        
        CGRect iconFrame ;
        if (self.iocn) {
            iconFrame = _chatMessage.isFirstRow ? self.contactIcon.frame : CGRectMake(10, 5, HEAD_AVARTA_HEIGHT, HEAD_AVARTA_HEIGHT);
        } else {
            iconFrame = _chatMessage.isFirstRow ? self.textImage.frame : CGRectMake(10, 5, HEAD_AVARTA_HEIGHT, HEAD_AVARTA_HEIGHT);
        }

        bubbleRect.origin.x = iconFrame.origin.x + iconFrame.size.width + 5;
        
        self.chatBuble.frame = bubbleRect;
    }
    
    if(![MESSAGE_TYPE_VIDEO isEqualToString:msgType]&&![MESSAGE_TYPE_IMAGE isEqualToString:msgType]){
        [self setBubbleBackground];
    }
    
    CGFloat originY = (self.chatBuble.frame.size.height - self.statusIcon.frame.size.height) / 2 + cellMargin;
    CGFloat originX;
    if (IS_EVENT_INCOMING(self.messageStatus)){//消息发送失败，显示失败红点
        originX =self.chatBuble.frame.origin.x +self.chatBuble.frame.size.width+STATUS_MARGIN;
    }else{
        originX = self.chatBuble.frame.origin.x - self.statusIcon.bounds.size.width - STATUS_MARGIN;
    }
    CGRect iconRect = self.statusIcon.frame;
    iconRect.origin = CGPointMake(originX, originY);
    self.statusIcon.frame = iconRect;
    
    cellHeight = self.chatBuble.frame.size.height+cellMargin*2;
    self.contentView.frame = CGRectMake(0,0,ScreenWid, cellHeight);
    
    chatViewCell.frame = CGRectMake(chatViewCell.frame.origin.x ,cellMargin, chatViewCell.frame.size.width,cellHeight) ;
    
    [self traitCollectionDidChange:self.traitCollection];
}

- (void) setStatusIcon{
    NSString* msgType = [self.chatMessage.jsonContent valueForKey:KEY_MESSAGE_TYPE];
    if(IS_EVENT_PROCESSING(_chatMessage.status)&&![MESSAGE_TYPE_TEXT isEqualToString:msgType]){
        self.statusIcon.hidden = NO;
        self.statusIcon.image = [UIImage imageNamed:@"mss_browseLoading"];//此处应该是进度条动画提示
        self.statusIcon.contentMode =UIViewContentModeScaleAspectFit;
    }else if(IS_EVENT_ATTACHFAILED(_chatMessage.status)||IS_EVENT_FAILED(_chatMessage.status)){
        self.statusIcon.hidden = NO;
        self.statusIcon.image = [UIImage imageNamed:@"Sending_failed_ico"];
        self.statusIcon.contentMode =UIViewContentModeScaleAspectFit;
    }else{
        if ([MESSAGE_TYPE_AUDIO isEqualToString:msgType] && IS_EVENT_INCOMING(self.chatMessage.status)&&!(self.chatMessage.msgRead)){//接收到，未读标记
            self.statusIcon.image = [UIImage imageNamed:@"audio_unread"];
            self.statusIcon.hidden = NO;
            self.statusIcon.contentMode =UIViewContentModeScaleAspectFit;
        }else{
            self.statusIcon.hidden = YES;
        }
    }

}
-(void)setBubbleBackground{
    switch (self.cellType) {
        case CellCornerTypeLT_RT_RB:
            self.chatBuble = [self makeBezierPathView:self.chatBuble tag:CellCornerTypeLT_RT_RB];
            break;
        case CellCornerTypeRT_RB:
            self.chatBuble = [self makeBezierPathView:self.chatBuble tag:CellCornerTypeRT_RB];
            break;
        case CellCornerTypeLB_RT_RB:
            self.chatBuble = [self makeBezierPathView:self.chatBuble tag:CellCornerTypeLB_RT_RB];
            break;
        case CellCornerTypeLT_LB_RT:
            self.chatBuble = [self makeBezierPathView:self.chatBuble tag:CellCornerTypeLT_LB_RT];
            break;
        case CellCornerTypeLT_LB:
            self.chatBuble = [self makeBezierPathView:self.chatBuble tag:CellCornerTypeLT_LB];
            break;
        case CellCornerTypeLT_LB_RB:
            self.chatBuble = [self makeBezierPathView:self.chatBuble tag:CellCornerTypeLT_LB_RB];
            break;
        default:
            break;
        
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

-(void)setleftimg:(NSIndexPath*)indexpath andBOOL:(BOOL)singel andArr:(NSArray*)arr
{
    
    ifnosingle = NO;
    
    if (indexpath.row==0) {
        self.textImage.hidden = NO;
        self.contactIcon.hidden = NO;
        
        if (IS_EVENT_INCOMING(self.messageStatus)) {
            [self loadContactIconWhichside:1];
        }
        else{
            [self loadContactIconWhichside:0];
        }
    }
    else
    {
        
        self.textImage.hidden = YES;
        self.contactIcon.hidden = YES;
        
        if (singel) {
            self.textImage.hidden = YES;
            self.contactIcon.hidden = YES;
            
        }else
        {
            self.textImage.hidden = NO;
            self.contactIcon.hidden = NO;
            
            if (indexpath.row>0) {
                
                HSChatMessage *lastchatMessage = arr[indexpath.row-1];
                
                //上一条是in,这条是out 或者上条out ,这条in
                if ((IS_EVENT_INCOMING(lastchatMessage.status)&& IS_EVENT_INCOMING(self.chatMessage.status))
                    ||(IS_EVENT_INCOMING(self.chatMessage.status)&& IS_EVENT_INCOMING(lastchatMessage.status))){
                    ifnosingle = YES;
                }
            }
            
            if (IS_EVENT_INCOMING(_chatMessage.status)){
                [self loadContactIconWhichside:1];
            }
            else
            {
                self.textImage.hidden = YES;
                self.contactIcon.hidden = YES;
            }
        }
        
    }
    
    
    UITapGestureRecognizer * tapUser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickUser)];
    
    self.contactIcon .userInteractionEnabled = YES;
    self.textImage.userInteractionEnabled  = YES;
    [self.contactIcon addGestureRecognizer:tapUser];
    [self.textImage addGestureRecognizer:tapUser];
    
}

-(void)loadContactIconWhichside:(int)side {
    
    if (side == 0) { // 信息页面右边自己的图标不展示
        self.contactIcon.hidden = YES;
        self.textImage.hidden = YES;
        self.iocnimage.hidden = YES;
        return ;
    }
    
    if (self.iocn) {
        self.contactIcon.hidden = NO;
        self.textImage.hidden = YES;
        if (!self.contactIcon) {
            
            CGRect temp = CGRectMake(10, 5, 36, 36);
            
//            if(ifnosingle){
//
//                temp = CGRectMake(10, 15+5, 36, 36);
//            }
            
            self.contactIcon = [[UIImageView alloc] initWithFrame:temp];
    
            
            self.contactIcon.layer.cornerRadius = 15.0;
            self.contactIcon.clipsToBounds = YES;
            self.contactIcon.image = self.iocn;
            
            NSLog(@"self.iocn=====%@",self.iocn);
            
            [self.contentView addSubview:self.contactIcon];
            
            
            [self.contactIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                
                make.top.equalTo(_chatBuble.mas_top).with.offset(0);
                
                make.right.equalTo(_chatBuble.mas_left).with.offset(-5);
                
                make.width.equalTo(@(HEAD_AVARTA_HEIGHT));
                
                make.height.equalTo(@(HEAD_AVARTA_HEIGHT));

            }];
        }
        
        self.contactIcon.image = self.iocn;
        
    } else {
        self.contactIcon.hidden = YES;
        self.textImage.hidden = NO;
        
        if (!_textImage) {
            
            CGRect temp2 = CGRectMake(10, 2, HEAD_AVARTA_HEIGHT, HEAD_AVARTA_HEIGHT);
            
//            if(ifnosingle){
//                temp2 = CGRectMake(10, 15+2, HEAD_AVARTA_HEIGHT, HEAD_AVARTA_HEIGHT);
//            }
            
            _textImage = [[TextImageView alloc] initWithFrame:temp2];
            _textImage.textImageLabel.font = [UIFont fontWithName:@"Arial" size:15];
            _textImage.raduis = 17.0;
            _textImage.layer.cornerRadius = _textImage.bounds.size.width / 2;
            _textImage.clipsToBounds = YES;
            [self.contentView addSubview:_textImage];
            
            
            [_textImage mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                
                make.top.equalTo(_chatBuble.mas_top).with.offset(-1);
                
                make.right.equalTo(_chatBuble.mas_left).with.offset(-5);
                
                make.width.equalTo(@(HEAD_AVARTA_HEIGHT));
                
                make.height.equalTo(@(HEAD_AVARTA_HEIGHT));
                
                
            }];
            
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
            display = [display stringByAppendingString:@"  "];
        }
        //  NSLog(@"display======%@",display);
        
        
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

-(void)clickUser{
    
    NSLog(@"click userIcon");
    if (_onUserClickBlock) {
        self.onUserClickBlock(self.chatMessage);
    }
    
}

-(void)longClickMessage{
    
    [self becomeFirstResponder];
    //设置菜单显示的位置 frame设置其文职 inView设置其所在的视图
    [[UIMenuController sharedMenuController] setTargetRect:self.chatBuble.frame inView:self.contentView];
    //将菜单控件设置为可见
    [UIMenuController sharedMenuController].menuVisible = YES;
    UIMenuItem *forward = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward",@"forward") action:@selector(forward:)];
    UIMenuItem *download = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"DownLoad",@"download") action:@selector(download:)];
    [[UIMenuController sharedMenuController] setMenuItems: @[forward,download]];
    [[UIMenuController sharedMenuController] update];
    
}

-(void)clickMessage{
    NSLog(@"click message");
    if(self.onMessageClickBlock){
        self.onMessageClickBlock(self.chatMessage,self.contentView);
    }
}
-(void)forward:(nullable id)sender{
    NSLog(@"click message");
    if(self.onMessageLongClickBlock){
        self.onMessageLongClickBlock(self.chatMessage,@selector(forward:),self.contentView);
    }
}
-(void)download:(nullable id)sender{
    NSLog(@"click message");
    if(self.onMessageLongClickBlock){
        self.onMessageLongClickBlock(self.chatMessage,@selector(download:),self.contentView);
    }
}

- (void)copy:(nullable id)sender{
    NSString* content = [self.chatMessage.jsonContent valueForKey:KEY_TEXT_CONTENT];
    content= (content==nil?NSLocalizedString(@"UnknowFormat_UnknowFormat", @"UnknowFormat_UnknowFormat"):content);
    [UIPasteboard generalPasteboard].string = content;
    if(self.onMessageLongClickBlock){
        self.onMessageLongClickBlock(self.chatMessage,@selector(copy:),self.contentView);
    }
}

- (void)delete:(nullable id)sender{
    [databaseManage deleteHistory:self.chatMessage.historyId];
    NSLog(@"click message");
    if(self.onMessageLongClickBlock){
        self.onMessageLongClickBlock(self.chatMessage,@selector(delete:),self.contentView);
    }
}

//是否可以成为第一相应
-(BOOL)canBecomeFirstResponder{
  return YES;
}

//是否可以接收某些菜单的某些交互操作
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if(chatContent==nil||self.chatMessage==nil||self.chatMessage.jsonContent==nil)
        return NO;
    NSString* msgType = [self.chatMessage.jsonContent valueForKey:KEY_MESSAGE_TYPE];
    if([MESSAGE_TYPE_TEXT isEqualToString:msgType]){
        if (action == @selector(delete:)||action == @selector(copy:)||action == @selector(forward:)) {
          return YES;
        }
    }else if([MESSAGE_TYPE_AUDIO isEqualToString:msgType]
             ||[MESSAGE_TYPE_IMAGE isEqualToString:msgType]
           ||[MESSAGE_TYPE_VIDEO isEqualToString:msgType]
           ||[MESSAGE_TYPE_FILE isEqualToString:msgType]){
            if (action == @selector(delete:)) {
              return YES;
            }
        if(action==@selector(download:))
        {
            if(self.chatMessage.status==INCOMING_ATTACHFAILED){
                return YES;
            }
        }
    }
    
    return NO;
}

-(UIView *)makeBezierPathView:(UIView *)origin tag:(int)tag{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:origin.bounds byRoundingCorners:tag cornerRadii:CGSizeMake(BUBBLE_CORNER, BUBBLE_CORNER)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = origin.bounds;
    maskLayer.path = maskPath.CGPath;
    origin.layer.mask = maskLayer;
    return origin;
}

-(void)setChatMessage:(HSChatMessage *)message headerImage:(UIImage *)header cellType:(CellCornerTypeOptions)type{
    self.cellType = type;
    self.messageStatus = message.status;
    self.iocn = header;
    self.chatMessage = message;
    
    [self bindContentView];
}

-(void)bindContentView{
    if(chatContent==nil||self.chatMessage==nil||self.chatMessage.jsonContent==nil)
        return;
    NSString* msgType = [self.chatMessage.jsonContent valueForKey:KEY_MESSAGE_TYPE];

    if(msgType==nil||[MESSAGE_TYPE_TEXT isEqualToString:msgType]){
        
        NSString* content = [self.chatMessage.jsonContent valueForKey:KEY_TEXT_CONTENT];
        content= ((msgType==nil||content==nil)?NSLocalizedString(@"UnknowFormat_UnknowFormat", @"UnknowFormat_UnknowFormat"):content);
        NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:content attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0], NSForegroundColorAttributeName: [UIColor blackColor] }];
        [PPStickerDataManager.sharedInstance replaceEmojiForAttributedString:attributedMessage font:[UIFont systemFontOfSize:16.0]];
        UILabel* lableView = chatContent.subviews[0];
        lableView.attributedText = attributedMessage;
        lableView.lineBreakMode = NSLineBreakByWordWrapping;
        lableView.numberOfLines = 0;
        lableView.preferredMaxLayoutWidth = chatContent.bounds.size.width;
        
    }else if([MESSAGE_TYPE_FILE isEqualToString:msgType]){
        NSArray*subViews =  chatContent.subviews;
        UILabel* viewfileName = subViews[0];
        UILabel* viewfileDesc = subViews[1];
        UIImageView* viewfielIcon = subViews[2];

        NSString* fileName =  [self.chatMessage.jsonContent valueForKey:KEY_FILE_NAME];
        NSString* filePath=  [self.chatMessage.jsonContent valueForKey:KEY_FILE_PATH];
        NSNumber* fileSize =[self.chatMessage.jsonContent valueForKey:KEY_FILE_SIZE];
        //        [file filesi
        NSString *doc =[HttpHelper docFilePath];
        
        viewfileName.text =fileName;
        if(fileSize>0){
            viewfileDesc.text = [self getReadAbleSize:fileSize.longValue];
        }else{
            viewfileDesc.text = [self fileSizeAtPath:[doc stringByAppendingPathComponent:filePath]];
        }
        viewfielIcon.image=[self getFileIcon:fileName];
    }else if([MESSAGE_TYPE_AUDIO isEqualToString:msgType]){
        NSArray*subViews =  chatContent.subviews;
        UIImageView* viewPlayer = subViews[0];
        UILabel* label= subViews[1];
        NSArray *animationImages;
        if(IS_EVENT_OUTGOING(_chatMessage.status)){
            animationImages = @[[UIImage imageNamed:@"voicel"], [UIImage imageNamed:@"voicel1"], [UIImage imageNamed:@"voicel2"]];
        }else{
            animationImages = @[[UIImage imageNamed:@"voicer"], [UIImage imageNamed:@"voicer1"], [UIImage imageNamed:@"voicer2"]];
        }
        
        [viewPlayer setImage:animationImages[1]];
        viewPlayer.animationImages = animationImages;
        viewPlayer.animationDuration = animationImages.count/3;
        
        [viewPlayer sizeToFit];
        label.text = [NSString stringWithFormat:@"%d''",_chatMessage.msglen];
        
    }else if([MESSAGE_TYPE_VIDEO isEqualToString:msgType]){
        NSArray*subViews =  chatContent.subviews;
        UIImageView* imageView = subViews[0];
        UIImageView* player = subViews[1];
        
        UIImage * image = [_chatMessage getImage];
        [imageView setImage:image];
        
        UIImage* playImage = [UIImage imageNamed:@"record_play_ico@2x"];
        [player setImage:playImage];
        [player sizeToFit];
        player.center = chatContent.center;//[cellimageview convertPoint:cellimageview.center fromView:cellimageview.superview];
        
    }else if([MESSAGE_TYPE_IMAGE isEqualToString:msgType]){
        UIImage * image = [_chatMessage getImage];
        UIImageView* imageView = chatContent.subviews[0];
        [imageView setImage:image];
    }

   if(UrlTest&&[MESSAGE_TYPE_AUDIO isEqualToString:msgType]){
        NSString* content = [self.chatMessage.jsonContent valueForKey:KEY_FILE_URL];
        NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:content attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0], NSForegroundColorAttributeName: [UIColor blackColor] }];
        [PPStickerDataManager.sharedInstance replaceEmojiForAttributedString:attributedMessage font:[UIFont systemFontOfSize:16.0]];
        ((UILabel*)chatContent.subviews[0]).attributedText = attributedMessage;
    }

    [self setStatusIcon];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"register  proccess=%p",self);
    NSString* obKey =@"playID";
    if ([keyPath isEqualToString:obKey]&&[object isKindOfClass:HSChatViewController.class]){
        NSInteger value = [[object valueForKey:obKey] intValue];
        NSString* messageType = [self.chatMessage.jsonContent valueForKey:KEY_MESSAGE_TYPE];
        if([MESSAGE_TYPE_AUDIO isEqualToString:messageType]) {
            UIImageView* view = chatContent.subviews[0];
            if(self.chatMessage.historyId == value){
                if(IS_EVENT_INCOMING_SUCESS(self.chatMessage.status)){//
                    self.chatMessage.msgRead = true;
                    self.statusIcon.hidden =TRUE;
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
//-(void)setlengthLab:(int)length{
//
//    label.text = [NSString stringWithFormat:@"%d''",length];
//
//    label.font = [UIFont  systemFontOfSize:13];
//
//    if (_isListen) {
//        label.textColor  =[UIColor grayColor];
//    }else
//    {
//        label.textColor  =[UIColor darkTextColor];
//    }
//}

-(UIImage*) getFileIcon:(NSString*)filename{
    NSString* imageName = @"";
    NSString* extension = [filename pathExtension];
    if(extension && [extension caseInsensitiveCompare:@"pdf"] == NSOrderedSame){
        imageName =@"file_pdf.png";
    }
    if(extension==nil||extension.length<=0){
        imageName = @"file_unknow.png";
    }else if((extension && [extension caseInsensitiveCompare:@"MP3"] == NSOrderedSame)||(extension && [extension caseInsensitiveCompare:@"arm"] == NSOrderedSame)||(extension && [extension caseInsensitiveCompare:@"wav"] == NSOrderedSame)){
        imageName = @"file_music.png";
    }else if((extension && [extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame)||(extension && [extension caseInsensitiveCompare:@"jpeg"] == NSOrderedSame)||(extension && [extension caseInsensitiveCompare:@"png"] == NSOrderedSame) ){
        imageName = @"file_image.png";

    }else if((extension && [extension caseInsensitiveCompare:@"ppt"] == NSOrderedSame) ){
        imageName = @"file_ppt.png";
    }else if((extension && [extension caseInsensitiveCompare:@"pdf"] == NSOrderedSame) ){
        imageName = @"file_pdf.png";
    }else if((extension && [extension caseInsensitiveCompare:@"mp4"] == NSOrderedSame) ){
        imageName = @"file_movi.png";
    }else if((extension && [extension caseInsensitiveCompare :@"txt"] == NSOrderedSame)||(extension && [extension caseInsensitiveCompare:@"html"] == NSOrderedSame)
             ||(extension && [extension caseInsensitiveCompare:@"log"] == NSOrderedSame) ||(extension && [extension caseInsensitiveCompare:@"ini"] == NSOrderedSame)){
        imageName = @"file_txt.png";
    }else{
        imageName = @"file_unknow.png";
    }
    
    return [UIImage imageNamed:imageName];
}
                                 
- (NSString*) fileSizeAtPath:(NSString*)filePath{
    long lSize=0;
    NSFileManager* manager = [NSFileManager defaultManager];

    if ([manager fileExistsAtPath:filePath]){
        
        lSize = (long)[[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        
    }else{
        NSLog(@"计算文件大小：文件不存在");
    }
    return [self getReadAbleSize:lSize];
}
                                 
 -(NSString*) getReadAbleSize:(long)filesize{
     float fSize = 0;
     NSString* result;
     if(filesize<0){
         result = @"empty file";
     }else if (filesize<1024){
         fSize = filesize;
         result = [NSString stringWithFormat:@"%0.2f B",fSize];
     }else if(filesize>>10<1024){
         fSize = filesize;
         fSize /=1024;
         result = [NSString stringWithFormat:@"%0.2f KB",fSize];
     }else if(filesize>>20<1024){
         fSize = filesize>>10;
         fSize/=1024;
         result = [NSString stringWithFormat:@"%0.2f MB",fSize];
     }
     return result;
 }

-(void)seticon:(UIImage*)img{
    
    
    self.iocn = img;
    
    
    //    _contactIcon .image = img;
    //
    //    if (img) {
    //
    //        _contactIcon.hidden = NO;
    //
    //        _textImage.hidden = YES;
    //    }else
    //    {
    //        _contactIcon.hidden = YES;
    //        _textImage.hidden = NO;
    //
    //    }
    //
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)showZoomImageView:(UITapGestureRecognizer *)tap

{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = [UIScreen mainScreen].bounds;
    
    bgView.backgroundColor = [UIColor blackColor];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
    
    UITapGestureRecognizer *tapBgView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    
    [bgView addGestureRecognizer:tapBgView];
    
    //必不可少的一步，如果直接把点击获取的imageView拿来玩的话，返回的时候，原图片就完蛋了
    
    UIImageView *tempImageView = (UIImageView*)tap.view;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:tempImageView.frame];
    
    imageView.image = tempImageView.image;
    
    [bgView addSubview:imageView];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        CGRect frame = imageView.frame;
        
        frame.size.width = bgView.frame.size.width;
        
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        
        frame.origin.x = 0;
        
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        
        imageView.frame = frame;
        
    }];
    
}

-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer

{
    [tapBgRecognizer.view removeFromSuperview];
}


-(void) resizeContentView:(HSChatMessage*)chatmessage{
    
    CGSize size = CGSizeMake(MAIN_SCREEN_WIDTH - 110,3000); //设置一个行高上限
    NSString* msgType = [self.chatMessage.jsonContent valueForKey:KEY_MESSAGE_TYPE];

    if([MESSAGE_TYPE_TEXT isEqualToString:msgType] ||msgType==nil){
        chatContent.frame = self.chatMessage.contentRect;
        UILabel* textLable = chatContent.subviews[0];
        textLable.frame =CGRectMake(bubbleLRGap,bubbleTBGap,
                                    chatContent.frame.size.width-bubbleLRGap*2,
                                    chatContent.frame.size.height-bubbleTBGap*2);
    }else if([MESSAGE_TYPE_FILE isEqualToString:msgType]){
        CGFloat maxContentW = MAIN_SCREEN_WIDTH - 160;
        chatContent.frame = self.chatMessage.contentRect;
        
        NSArray*subViews =  chatContent.subviews;
        
        UILabel* viewfileName = subViews[0];
        UILabel* viewfileDesc = subViews[1];
        UIImageView* viewfielIcon = subViews[2];
        
        int fileIconWith =40, fileIconHeight=40;
        int filenameWidth =maxContentW -fileIconWith-bubbleLRGap-10,filenameHeight=[viewfileName.font pointSize];
        int fileDescWith =filenameWidth,fileDescHeight =15;
        
        int left=bubbleLRGap,top =bubbleTBGap;
        
        viewfileName.frame = CGRectMake(left, top, filenameWidth, filenameHeight);
        viewfileDesc.frame = CGRectMake(left, top+filenameHeight+5, fileDescWith, fileDescHeight);
        viewfielIcon.frame = CGRectMake(chatContent.frame.size.width -fileIconWith-bubbleLRGap,
                                        top,fileIconWith,fileDescHeight+filenameHeight);
    }else if([MESSAGE_TYPE_VIDEO isEqualToString:msgType]){
        chatContent.frame = self.chatMessage.contentRect;
        
        UIImageView *imageView = chatContent.subviews[0];
        imageView.frame = chatContent.frame;
        
        UIImageView *player = chatContent.subviews[1];
        player.center = [imageView convertPoint:imageView.center fromView:imageView.superview];
        
    }else if([MESSAGE_TYPE_IMAGE isEqualToString:msgType]){
        chatContent.frame = self.chatMessage.contentRect;
        
        UIImageView *imageView = chatContent.subviews[0];
        imageView.frame = chatContent.frame;
    }else if([MESSAGE_TYPE_AUDIO isEqualToString:msgType]){
        chatContent.frame = self.chatMessage.contentRect;
        UIImageView *player = chatContent.subviews[0];
        player.frame = CGRectMake(bubbleLRGap,bubbleTBGap, VOICE_ICON_HEIGHT,VOICE_ICON_HEIGHT);
        UIImageView *timelable = chatContent.subviews[1];

        timelable.frame =CGRectMake(player.frame.origin.x+player.frame.size.width+5,bubbleTBGap, chatContent.frame.size.width - bubbleLRGap*2-VOICE_ICON_HEIGHT-5,chatContent.frame.size.height - bubbleTBGap*2);
        //timelable.frame = chatContent.frame;
    }
#ifdef DEBUG
    else if(UrlTest&&[MESSAGE_TYPE_AUDIO isEqualToString:msgType]){
            NSString* content = [self.chatMessage.jsonContent valueForKey:KEY_FILE_URL];
            NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
            
            NSMutableString * tempstr = [[NSMutableString alloc]initWithString: content];
            
            NSString *regex = @"\\[[^\\]]*\\]";
            NSError *error;
            NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                     options:NSRegularExpressionCaseInsensitive
                                                                                       error:&error];
            // 对str字符串进行匹配
            NSArray *matches = [regular matchesInString:tempstr
                                                options:0
                                                  range:NSMakeRange(0, tempstr.length)];
            
            NSMutableArray*  result = [[NSMutableArray alloc]init];
            
            // 遍历匹配后的每一条记录
            for (NSTextCheckingResult *match in matches) {
                NSRange range = [match range];
                NSString *mStr = [tempstr substringWithRange:range];
                [result addObject:mStr];
                
            }
            NSString* newstr = content;
            //1000 110
            //   NSLog(@"newstr.length===%d",newstr.length);
            
            NSString *targetStr = @"1000";
            
            if (newstr.length<100) {
                targetStr = @"110";
            }
            
            for (NSString *regStr in result) {
                newstr = [newstr stringByReplacingOccurrencesOfString:regStr withString:targetStr];
            }
            
            CGSize labelSize = [newstr boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
            CGFloat maxContentW = MAIN_SCREEN_WIDTH - 110;
            CGRect frame = CGRectMake(15, 2+5, labelSize.width > maxContentW ? maxContentW+3 : labelSize.width+3, labelSize.height + 30/4);
            
            chatContent.frame = frame;
    }
#endif
}
@end
