//
//  MessageCell.m
//  PortGo
//
//  Created by Joe Lepple on 4/13/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "MessageCell.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "NSString+HSFilterString.h"

#import "UIView+DragBlast.h"
#import "PPStickerInputView.h"



@implementation MessageCell
@synthesize mHistoryID;
@synthesize labelDisplayName;
@synthesize labelDate;
@synthesize labelContent;
@synthesize cellSeperatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColorLight"];
    }
    else{
        bkColor = [UIColor lightGrayColor];
    }
    
    cellSeperatorView.backgroundColor = bkColor;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.imageHeadView.layer.cornerRadius = self.imageHeadView.bounds.size.height / 2;
    self.imageHeadView.clipsToBounds = YES;
    
    self.countLabel.layer.cornerRadius = self.countLabel.bounds.size.height / 2;
    self.countLabel.clipsToBounds = YES;
    
    _textImage = [[TextImageView alloc] initWithFrame:CGRectMake(15, 10, 55, 55)];
    _textImage.textImageLabel.font = [UIFont fontWithName:@"Arial" size:22];
    _textImage.raduis = 27;
    [self.contentView addSubview:_textImage];
    
    cellSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(10,self.contentView.frame.size.height-0.5, self.bounds.size.width, 0.5)];
    [self.contentView addSubview:cellSeperatorView];
}

-(void)layoutSubviews {
    [super layoutSubviews]; //if forget this method ..  you fucked
    
    for (UIView *subView in self.subviews) {
        
        if ([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
            
            if (mMediaType == MediaType_IMMsg) {
                UIButton *accept = subView.subviews[0];
                [accept setBackgroundColor:[UIColor grayColor]];
                [accept setTitle:NSLocalizedString(@"Reject", @"Reject") forState:UIControlStateNormal];
                accept.titleLabel.font = [UIFont systemFontOfSize:12];
                [self setButtonContentCenter:accept];
                
                UIButton *reject = subView.subviews[1];
                [reject setBackgroundColor:MAIN_COLOR];
                [reject setTitle:NSLocalizedString(@"Accept", @"Accept") forState:UIControlStateNormal];
                reject.titleLabel.font = [UIFont systemFontOfSize:12];
                [self setButtonContentCenter:reject];
                
            } else {
                UIButton *deleteBtn = subView.subviews[0];
                [deleteBtn setBackgroundColor:[UIColor redColor]];
                [deleteBtn setTitle:NSLocalizedString(@"Delete", @"Delete") forState:UIControlStateNormal];
                deleteBtn.titleLabel.font = [UIFont systemFontOfSize:12];
                [self setButtonContentCenter:deleteBtn];
                
                UIButton *vedioBtn = subView.subviews[1];
                [vedioBtn setBackgroundColor:[UIColor colorWithRed:28.0/255 green:185.0/255 blue:126.0/255 alpha:1]];
                [vedioBtn setTitle:NSLocalizedString(@"Video Call", @"Video Call") forState:UIControlStateNormal];
                vedioBtn.titleLabel.font = [UIFont systemFontOfSize:12];
                [self setButtonContentCenter:vedioBtn];
                
                UIButton *audioBtn = subView.subviews[2];
                [audioBtn setBackgroundColor:[UIColor colorWithRed:29.0/255 green:172.0/255 blue:239.0/255 alpha:1]];
                [audioBtn setTitle:NSLocalizedString(@"Audio Call", @"Audio Call") forState:UIControlStateNormal];
                audioBtn.titleLabel.font = [UIFont systemFontOfSize:12];
                [self setButtonContentCenter:audioBtn];
            }
        }
    }
    
    [self.cellSeperatorView setFrame:CGRectMake(cellSeperatorView.frame.origin.x, cellSeperatorView.frame.origin.y, self.frame.size.width, 0.5)];
    [self traitCollectionDidChange:self.traitCollection];
}



-(void)setButtonContentCenter:(UIButton *)button {
    CGSize imgViewSize,titleSize,btnSize;
    UIEdgeInsets imageViewEdge,titleEdge;
    CGFloat heightSpace = 10.0f;
    
    //设置按钮内边距
    imgViewSize = button.imageView.bounds.size;
    titleSize = button.titleLabel.bounds.size;
    btnSize = button.bounds.size;
    
    imageViewEdge = UIEdgeInsetsMake(heightSpace,0.0, btnSize.height -imgViewSize.height - heightSpace, - titleSize.width);
    [button setImageEdgeInsets:imageViewEdge];
    
    titleEdge = UIEdgeInsetsMake(heightSpace,0.0, btnSize.height -titleSize.height - heightSpace, 0.0);
    [button setTitleEdgeInsets:titleEdge];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (!self.isEditing) {
        return ;
    }
    
    for (UIControl *control in self.subviews) {
        if (![control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            continue;
        }
        
        for (UIView *subView in control.subviews) {
            if (![subView isKindOfClass: [UIImageView class]]) {
                continue;
            }
            
            UIImageView *imageView = (UIImageView *)subView;
            if (selected) {
                imageView.image = [UIImage imageNamed:@"checkbox_sel"]; // 选中时的图片
            } else {
                imageView.image = [UIImage imageNamed:@"checkbox_pre"];   // 未选中时的图片
            }
        }
    }

    // Configure the view for the selected state
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        for (UIControl *control in self.subviews) {
            if (![control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
                continue;
            }
            
            for (UIView *subView in control.subviews) {
                if (![subView isKindOfClass: [UIImageView class]]) {
                    continue;
                }
                
                UIImageView *imageView = (UIImageView *)subView;
                if (self.selected) {
                    imageView.image = [UIImage imageNamed:@"checkbox_sel"]; // 选中时的图片
                } else {
                    imageView.image = [UIImage imageNamed:@"checkbox_pre"];   // 未选中时的图片
                }
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

- (void)setChatHistory:(History*)chatHistory
{
    if(chatHistory){
        
        self.countLabel.layer.masksToBounds = YES;
        self.countLabel.tapBlast = YES;
        self.countLabel.dragBlast = NO;

        self.countLabel.userInteractionEnabled = YES;

        [self.countLabel blastCompletion:^(BOOL finished) {
            if (finished) {
//                NSLog(@"taptaptap = %d",self.countLabel.tag);
                if (self.RedDelegate) {
                    self.RedDelegate(self.countLabel.tag);
                }
            }
        }];
        
        // content
        
        NSLog(@"labelContent.attributedText==%@",labelContent.attributedText);
        
        UIColor* bkColor;
        if (@available(iOS 11.0, *)) {
            bkColor = [UIColor colorNamed:@"mainFrontColor"];
        }
        else{
            bkColor = [UIColor blackColor];
        }
        NSDictionary *jsonConent = [chatHistory getJsonContent];
        NSString *msgType = [jsonConent valueForKey:KEY_MESSAGE_TYPE];
        NSString *loadUrl = [jsonConent valueForKey:KEY_FILE_URL];
        NSString *fileName = [jsonConent valueForKey:KEY_FILE_NAME];
        NSString* messageContent ;
        if([MESSAGE_TYPE_TEXT isEqualToString:msgType]){
            messageContent = [jsonConent valueForKey:KEY_TEXT_CONTENT];
        }else{
            messageContent = fileName;
        }
        NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:messageContent attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:14.0], NSForegroundColorAttributeName:bkColor}];
        [PPStickerDataManager.sharedInstance getAlterString:attributedMessage font:[UIFont systemFontOfSize:14.0]];
        
        labelContent.attributedText = attributedMessage;
        
        // date
        labelDate.text = [@"" getTimeStart:chatHistory.mTimeStart];

        NSDictionary *dic = [contactView numbers2ContactsMapper];
        
     //   NSLog(@"dic======%@",dic);
        HSChatSession* chatSession = [databaseManage findChatSessionById:chatHistory.mSessionId];
        NSString *temp = chatSession.mRemoteUri;
        
        if ([temp rangeOfString:@"@"] .location == NSNotFound) {
            temp = [NSString stringWithFormat:@"%@@%@",temp,shareAppDelegate.portSIPHandle.mAccount.userDomain ];
        }
        
        
        NSLog(@"temp===%@",temp);
        
        Contact *contact = [dic objectForKey:temp];
        
        
        //show the head image
        if(contact){
            if(contact.picture){
                self.textImage.hidden = YES;
                self.imageHeadView.hidden = NO;
                self.imageHeadView.image = [UIImage imageWithData:contact.picture];
            } else {
                self.imageHeadView.hidden = YES;
                _textImage.hidden = NO;
                NSString* display = contact.displayName;
                if(display.length<2){
                    display = [display stringByAppendingString:@" "];
                }
                
                if ([self includeChinese:display]) {
                    if (display.length < 2) {
                        _textImage.string = [display substringToIndex:1];
                    } else {
                        NSString* sub = [display substringToIndex:2];
                        if ([self includeChinese:sub]) {
                            _textImage.textImageLabel.text = [display substringToIndex:1];
                        } else {
                            _textImage.textImageLabel.text = [display substringToIndex:2];
                        }
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
            
            self.labelDisplayName.text = contact.displayName;
        } else {
            _imageHeadView.hidden = YES;
            _textImage.hidden = NO;
            
            NSString *displayName = [chatHistory.mRemotePartyDisplayName isEqualToString:@""] ? [chatSession.mRemoteUri getUriUsername:chatSession.mRemoteUri] :chatSession.mRemoteDisname;
            
            
            if(displayName.length<2){
                displayName = [displayName stringByAppendingString:@" "];
            }
        
            
            NSArray * contactViewARR = [contactView contacts];
            
            
           // NSLog(@"mRemoteParty============808===%@",history.mRemoteParty);
            
            BOOL isdelete = YES;
            
            
            for (Contact *con in  contactViewARR   ) {
                for (NSDictionary * dic  in  con.IPCallNumbers) {
                    if ([chatSession.mRemoteUri isEqualToString:[dic objectForKey:NSLocalizedString(@"VoIP Call",@"VoIP Call")]]) {
                        
                        displayName =con.displayName;
                        isdelete = NO;
                        break;
                    }
                }
            }

            if (isdelete) {
                
                NSString * temp = chatSession.mRemoteUri;
                NSArray * arr = [temp componentsSeparatedByString:@"@"];
                if (arr.count>0) {
                    displayName = [arr objectAtIndex:0];
                }
            }
            
            if (displayName.length >= 2) {
                if ([self includeChinese:displayName]) {
                    _textImage.textImageLabel.text = [displayName substringToIndex:1];
                } else {
                    _textImage.textImageLabel.text = [displayName substringToIndex:2];
                }
                
            } else {
                _textImage.textImageLabel.text = [displayName substringToIndex:1];
            }
            
            
            self.labelDisplayName.text = displayName;

        }
        
//        if (IS_EVENT_FAILED(chatSession.mStatus)||IS_EVENT_ATTACHFAILED(chatSession.mStatus)) {//失败的消息，用红色字体
//            self.labelDisplayName.textColor = [UIColor redColor];
//        } else {
//            bkColor = [UIColor darkGrayColor];
//            labelDisplayName.textColor = bkColor;
//        }
        
    }
}

- (void)setChatSession: (HSChatSession*)chatSession
{
    if(chatSession){
        
        self.countLabel.layer.masksToBounds = YES;
        self.countLabel.tapBlast = YES;
        self.countLabel.dragBlast = NO;

        self.countLabel.userInteractionEnabled = YES;

        [self.countLabel blastCompletion:^(BOOL finished) {
            if (finished) {
//                NSLog(@"taptaptap = %d",self.countLabel.tag);
                if (self.RedDelegate) {
                    self.RedDelegate(self.countLabel.tag);
                }
            }
        }];
        
        // content
        
        NSLog(@"labelContent.attributedText==%@",labelContent.attributedText);
        
        UIColor* bkColor;
        if (@available(iOS 11.0, *)) {
            bkColor = [UIColor colorNamed:@"mainFrontColor"];
        }
        else{
            bkColor = [UIColor blackColor];
        }
        
        NSString* messageContent = chatSession.mStatus;
        NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:messageContent attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:14.0], NSForegroundColorAttributeName:bkColor}];
        [PPStickerDataManager.sharedInstance getAlterString:attributedMessage font:[UIFont systemFontOfSize:14.0]];
        
        labelContent.attributedText = attributedMessage;
        
        // date
        labelDate.text = [@"" getTimeStart:chatSession.mLastTimeConnect];
        NSDictionary *dic = [contactView numbers2ContactsMapper];
        
     //   NSLog(@"dic======%@",dic);
        
        NSString *temp = chatSession.mRemoteUri;
        
        if ([temp rangeOfString:@"@"] .location == NSNotFound) {
            temp = [NSString stringWithFormat:@"%@@%@",temp,shareAppDelegate.portSIPHandle.mAccount.userDomain ];
        }
        
        
        NSLog(@"temp===%@",temp);
        
        Contact *contact = [dic objectForKey:temp];
        
        
        //show the head image
        if(contact){
            if(contact.picture){
                self.textImage.hidden = YES;
                self.imageHeadView.hidden = NO;
                self.imageHeadView.image = [UIImage imageWithData:contact.picture];
            } else {
                self.imageHeadView.hidden = YES;
                _textImage.hidden = NO;
                NSString* display = contact.displayName;
                if(display.length<2){
                    display = [display stringByAppendingString:@" "];
                }
                
                if ([self includeChinese:display]) {
                    if (display.length < 2) {
                        _textImage.string = [display substringToIndex:1];
                    } else {
                        NSString* sub = [display substringToIndex:2];
                        if ([self includeChinese:sub]) {
                            _textImage.textImageLabel.text = [display substringToIndex:1];
                        } else {
                            _textImage.textImageLabel.text = [display substringToIndex:2];
                        }
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
            
            self.labelDisplayName.text = contact.displayName;
        } else {
            _imageHeadView.hidden = YES;
            _textImage.hidden = NO;
            
            NSString *displayName = [chatSession.mRemoteDisname isEqualToString:@""] ? [chatSession.mRemoteUri getUriUsername:chatSession.mRemoteUri] : chatSession.mRemoteDisname;
            
            
            if(displayName.length<2){
                displayName = [displayName stringByAppendingString:@" "];
            }
        
            
            NSArray * contactViewARR = [contactView contacts];
            
            
           // NSLog(@"mRemoteParty============808===%@",history.mRemoteParty);
            
            BOOL isdelete = YES;
            
            
            for (Contact *con in  contactViewARR   ) {
                for (NSDictionary * dic  in  con.IPCallNumbers) {
                    if ([chatSession.mRemoteUri isEqualToString:[dic objectForKey:NSLocalizedString(@"VoIP Call",@"VoIP Call")]]) {
                        
                        displayName =con.displayName;
                        isdelete = NO;
                        break;
                    }
                }
            }

            if (isdelete) {
                
                NSString * temp = chatSession.mRemoteUri ;
                NSArray * arr = [temp componentsSeparatedByString:@"@"];
                if (arr.count>0) {
                    displayName = [arr objectAtIndex:0];
                }
            }
            
            if (displayName.length >= 2) {
                if ([self includeChinese:displayName]) {
                    _textImage.textImageLabel.text = [displayName substringToIndex:1];
                } else {
                    _textImage.textImageLabel.text = [displayName substringToIndex:2];
                }
                
            } else {
                _textImage.textImageLabel.text = [displayName substringToIndex:1];
            }
            
            
            self.labelDisplayName.text = displayName;

        }
        
//        if (IS_EVENT_FAILED(chatSession.mStatus)||IS_EVENT_ATTACHFAILED(chatSession.mStatus)) {//失败的消息，用红色字体
//            self.labelDisplayName.textColor = [UIColor redColor];
//        } else {
//            bkColor = [UIColor darkGrayColor];
//            labelDisplayName.textColor = bkColor;
//        }
        
    }
}

//判断是否为附件信息

-(NSString* )DecideWhetherToAttachInformation:(NSString*)message{
    
    
    if (message.length <4) {
        return @"" ;
        
    }
    
    NSString * tempstr = [message substringFromIndex:message.length-4];
    
//    NSLog(@"是否是附件信息 tempstr======%@",tempstr);
    
    return tempstr;
    
    
}
@end
