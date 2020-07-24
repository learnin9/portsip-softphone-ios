//
//  HSRecentCell.m
//  PortGo
//
//  Created by MrLee on 14-9-28.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSRecentCell.h"
#import "History.h"
#import "AppDelegate.h"
#import "TextImageView.h"
#import "NSString+HSFilterString.h"
#import "JRDB.h"
#import "callListModel.h"

@interface HSRecentCell()
@property (weak, nonatomic) IBOutlet UIImageView *callStateImageView;
//@property (weak, nonatomic) IBOutlet UILabel *callTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *callLongLabel;
@property (weak, nonatomic) IBOutlet UILabel *callBeginTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remotePartyLable;
@property (weak, nonatomic) IBOutlet UIImageView *outInStateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mediaTypeImageview;
@property (strong, nonatomic) TextImageView *textImage;

@end

@implementation HSRecentCell

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
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
                imageView.image = nil;
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

-(void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIView *seperator in self.subviews) {
        if ([seperator isMemberOfClass:NSClassFromString(@"_UITableViewCellSeparatorView")]) {
            seperator.alpha = 0.4;
        }
    }
}


-(void)awakeFromNib {
    [super awakeFromNib];
    _textImage = [[TextImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _textImage.center = CGPointMake(30, self.bounds.size.height / 2);
    _textImage.textImageLabel.font = [UIFont fontWithName:@"Arial" size:20];
    _textImage.raduis = 20.0;
    [self.contentView addSubview:_textImage];
    
    _callStateImageView.layer.cornerRadius = _callStateImageView.bounds.size.width / 2;
    _callStateImageView.clipsToBounds = YES;
}

 
#pragma mark-
#pragma mark  设置通话记录cell

- (void)setHistory:(History *)history
{
    if(history){
        _history = history;
        
        NSDictionary *dic = [contactView numbers2ContactsMapper];
        
        
        NSString *temp = [[history mRemoteParty] getUriUsername:history.mRemoteParty];
        
        if ([temp rangeOfString:@"@"] .location == NSNotFound) {
            
            temp = [NSString stringWithFormat:@"%@@%@",temp,shareAppDelegate.portSIPHandle.mAccount.userDomain ];
            
            
        }
        
        Contact *contact = [dic objectForKey:temp];
        
        
        if (contact) {
            if (contact.picture) {
                _callStateImageView.hidden = NO;
                _textImage.hidden = YES;
                _callStateImageView.image = [UIImage imageWithData:contact.picture];
            } else {
                _callStateImageView.hidden = YES;
                _textImage.hidden = NO;
                NSString* displayName =contact.displayName;
                if(displayName.length<2){
                    displayName = [displayName stringByAppendingString:@" "];
                }
                
                if ([self includeChinese:displayName]) {
                    if (displayName.length < 2) {
                        _textImage.string = [displayName substringToIndex:1];
                    } else {
                        NSString* sub = [displayName substringToIndex:2];
                        if ([self includeChinese:sub]) {
                            _textImage.textImageLabel.text = [displayName substringToIndex:1];
                        } else {
                            _textImage.textImageLabel.text = [displayName substringToIndex:2];
                        }
                    }
                    
                } else {
                    
                         NSString * tempstr = [displayName substringFromIndex:displayName.length-1];
                    
                    if ([displayName containsString:@" "] && ![tempstr isEqualToString:@" "]) {
                        NSArray *strs = [displayName componentsSeparatedByString:@" "];
                        NSString *first = strs[0];
                        NSString *last = strs[1];
                        
                        if (first.length >=1 && last.length >=1) {
                            
                              _textImage.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],[last substringToIndex:1]];
                        }
                      
                    } else {
                        _textImage.textImageLabel.text = [displayName substringToIndex:2];
                    }
                }
            }
            if (_history.historyCount > 1) {
                _accountLabel.text = [NSString stringWithFormat:@"%@(%d)",contact.displayName == nil ? _history.mRemotePartyDisplayName : contact.displayName, _history.historyCount];
            } else {
                _accountLabel.text = [NSString stringWithFormat:@"%@",contact.displayName == nil ? _history.mRemotePartyDisplayName : contact.displayName];
            }
            
            
            //从本地匹配原始拨叫号码
//            NSArray *calllistarray  = J_Select(callListModel).And(@"dialplancallnumber").like(_history.mRemoteParty).list;
//
//            callListModel *model = [calllistarray lastObject];
//
//            _remotePartyLable.text = model.callnumber;
//
//            if (model.callnumber ==nil) {
            
                _remotePartyLable.text  = _history.mRemoteParty;
                
            
            NSString * tempstr =_remotePartyLable.text;
            
            if ([tempstr rangeOfString:@"@"].location!=NSNotFound) {
                
                NSArray *strs = [tempstr componentsSeparatedByString:@"@"];
                
                _remotePartyLable.text = strs[0];
                
                
            }
            
            
     //       }
            
        } else {
            _callStateImageView.hidden = YES;
            _textImage.hidden = NO;
            
       //     NSString *display = [_history.mRemotePartyDisplayName isEqualToString:@""] ? [_history.mRemoteParty getUriUsername:_history.mRemoteParty] : _history.mRemotePartyDisplayName;
            
              NSString *display = _history.mRemotePartyDisplayName;

            
         //   NSLog(@"mRemoteParty=====%@",_history.mRemoteParty);
            
            
            
            //从本地匹配原始拨叫号码
//            NSArray *calllistarray  = J_Select(callListModel).And(@"dialplancallnumber").like(_history.mRemoteParty).list;
//
//
//
//            callListModel *model = [calllistarray lastObject];
//
//            _remotePartyLable.text = model.callnumber;
//
//            for (callListModel * modein in calllistarray) {
//
//                NSLog(@"callnumber=%@",modein.callnumber);
//            }
//
//            if (model.callnumber ==nil) {
            
                _remotePartyLable.text  = _history.mRemoteParty;
                
                
            NSString * tempPartyLable =_remotePartyLable.text;
            
            if ([tempPartyLable rangeOfString:@"@"].location!=NSNotFound) {
                
                NSArray *strs = [tempPartyLable componentsSeparatedByString:@"@"];
                
                _remotePartyLable.text = strs[0];
                
                
            }
                
      //      }
            
            
          
            NSArray * contactViewARR = [contactView contacts];
            
            
       
//            NSString * tempstr = model.callnumber;
//
//            if (model.callnumber ==nil) {
            
              NSString*  tempstr = _history.mRemoteParty;
                
      //      }
            
            BOOL  isdelete = YES;
            
            
            for (Contact *con in  contactViewARR   ) {
                

                
                for (NSDictionary * dic  in  con.IPCallNumbers) {
            
 
                    if ([tempstr isEqualToString:[dic objectForKey:NSLocalizedString(@"VoIP Call",@"VoIP Call")]]) {
                        
            //            NSLog(@"con.displayName=====%@",con.displayName);
                        display =con.displayName;
                        
                        isdelete = NO;
                        
                        
    
                        
                        break;
                        
                    }
              
                }
                
                
                
                
            }
            
            
            if (isdelete) {

                NSString * temp = _remotePartyLable.text ;

                NSArray * arr = [temp componentsSeparatedByString:@"@"];

                if (arr.count>0) {

                    display = [arr objectAtIndex:0];

                }


            }
                

            if(display.length<2){
                display = [display stringByAppendingString:@" "];
            }
            
            if (display.length >= 2) {
                if ([self includeChinese:display]) {
                    
                    
                    _textImage.string = [display substringToIndex:1];
                    
                    
                } else {
                    _textImage.string = [display substringToIndex:2];
                }
            } else {
                
                _textImage.string = [display substringToIndex:1];
                
            }
            
            if (_history.historyCount > 1) {
                _accountLabel.text = [NSString stringWithFormat:@"%@(%d)",display,_history.historyCount];
            } else {
                _accountLabel.text = [NSString stringWithFormat:@"%@",display];
            }
        }
        
        _remoteParty = _history.mRemoteParty;
//        _accountLabel.text = [shareAppDelegate getShortRemoteParty:_remoteParty];
        
        
        
        CGSize size = CGSizeMake(180,21); //设置一个行高上限
        NSDictionary *attribute = @{NSFontAttributeName: self.accountLabel.font};
        CGSize labelSize = [self.accountLabel.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
        CGRect frame  = _accountLabel.frame;
        frame.size = labelSize;
        CGFloat length = _accountLabel.frame.origin.x + labelSize.width + _mediaTypeImageview.frame.size.width + 5;
        if (length > self.bounds.size.width - _accountLabel.frame.origin.x) {
            frame.size.width = self.bounds.size.width - _accountLabel.frame.origin.x - _mediaTypeImageview.frame.size.width - 5;
            _accountLabel.frame = frame;
        } else {
            _accountLabel.frame = frame;
        }
        
        
        CGRect mediaFrame = _mediaTypeImageview.frame;
        mediaFrame.origin.x = _accountLabel.frame.size.width + _accountLabel.frame.origin.x + 5;
        _mediaTypeImageview.frame = mediaFrame;
        
       // _remotePartyLable.text = _history.mRemoteParty;
        
        
    
        
        
        
        
        // date
        _callBeginTimeLabel.text = [_history getTimeStart];
        
        //call time
        //呼叫事件，没有attach失败状态
        if (IS_EVENT_FAILED(_history.mStatus)) {
            _callLongLabel.text = NSLocalizedString(@"unconnect", @"unconnect");
            _callLongLabel.textColor = [UIColor redColor];
        } else {
            _callLongLabel.text = [_history getTimeDuration];
            _callLongLabel.textColor = [UIColor lightGrayColor];
        }
        
        
        switch ([_history mMediaType]) {
            case MediaType_Audio:
            {
//                _callTypeLabel.text = NSLocalizedString(@"Audio", @"Audio");
                _mediaTypeImageview.image = [UIImage imageNamed:@"recent_callstyle_audio_ico"];
                CGRect medieaImage = _mediaTypeImageview.bounds;
                medieaImage.size.height = 14.0;
                medieaImage.size.width = 14.0;
                _mediaTypeImageview.bounds = medieaImage;
                break;
            }
            case MediaType_Video:
            {
//                _callTypeLabel.text = NSLocalizedString(@"Video", @"Video");
                _mediaTypeImageview.image = [UIImage imageNamed:@"recent_callstyle_vedio_ico"];
                
                break;
            }
            case MediaType_AudioVideo:
            {
//                _callTypeLabel.text = NSLocalizedString(@"Video", @"Video");
                _mediaTypeImageview.image = [UIImage imageNamed:@"recent_callstyle_vedio_ico"];
                CGRect medieaImage = _mediaTypeImageview.bounds;
                medieaImage.size.height = 12.0;
                medieaImage.size.width = 19.0;
                _mediaTypeImageview.bounds = medieaImage;
                break;
            }
            default:
//                _callTypeLabel.text = NSLocalizedString(@"Unknown", @"Unknown");
                break;
        }
        
        // status
        if(IS_EVENT_INCOMING(_history.mStatus)){
            if (IS_EVENT_FAILED(_history.mStatus)){
                    _outInStateImageView.image = [UIImage imageNamed:@"recent_callin_miss"];
                    _accountLabel.textColor = [UIColor redColor];
            }else{
                _outInStateImageView.image = [UIImage imageNamed:@"recent_callint_ico"];
                _accountLabel.textColor = [UIColor darkGrayColor];
            }
        }else{
            if(IS_EVENT_OUTGOING_FAILED(_history.mStatus)){
                _outInStateImageView.image = [UIImage imageNamed:@"recent_callout_ico"];
                _accountLabel.textColor = [UIColor redColor];
            }else{
                
                _outInStateImageView.image = [UIImage imageNamed:@"recent_callout_ico"];
                _accountLabel.textColor = [UIColor darkGrayColor];
            }
        }
            
    }

}
@end
