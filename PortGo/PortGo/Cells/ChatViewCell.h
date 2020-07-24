//
//  ChatViewCell.h
//  PortGo
//
//  Created by 今言网络 on 2017/6/27.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
// aim to fuck you!!!!

#import <UIKit/UIKit.h>
#import "HSChatMessage.h"
#import "TextImageView.h"

#import "Contact.h"

typedef NS_OPTIONS(NSUInteger, CellCornerTypeOptions) {
    CellCornerTypeLT_RT_RB = 1<<0 | 1<<1 | 1<<3,
    CellCornerTypeRT_RB = 1<<1 | 1<<3,
    CellCornerTypeLB_RT_RB = 1<<2 | 1<<1 | 1<<3,
    CellCornerTypeLT_LB_RT = 1<<0 | 1<<2 | 1<<1,
    CellCornerTypeLT_LB = 1<<0 | 1<<2,
    CellCornerTypeLT_LB_RB = 1<<0 | 1<<2 | 1<<3
};

static NSString* CHATVIEW_TYPE_TEXT=@"mimetypetext";
static NSString* CHATVIEW_TYPE_FILE=@"mimetypefile";
static NSString* CHATVIEW_TYPE_VIDEO=@"mimetypevideo";
static NSString* CHATVIEW_TYPE_AUDIO=@"mimetypeaudio";
static NSString* CHATVIEW_TYPE_IMAGE=@"mimetypeimage";

@interface ChatViewCell : UITableViewCell
{
    
    BOOL  ifnosingle;
//    UIImageView * cellimageview;
    UIView* chatContent;
    UIView* chatViewCell;
    
}
@property (nonatomic, strong) TextImageView *textImage;
@property (nonatomic, strong) UIImageView *contactIcon;
@property (strong, nonatomic) UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UIView *chatBuble;
@property (weak, nonatomic) IBOutlet UIImageView *statusIcon;

@property (nonatomic, assign) CellCornerTypeOptions cellType;

@property  BOOL  isListen;
@property (assign) int messageStatus;
@property (weak, nonatomic) IBOutlet UIImageView *iocnimage;

@property (strong, nonatomic) UIImage *iocn;

@property (nonatomic, strong) HSChatMessage *chatMessage;
@property  NSString* messageTYPE;  //表示附件类型

@property  Contact * mycontact;

-(void)setChatMessage:(HSChatMessage *)message headerImage:(UIImage *)header cellType:(CellCornerTypeOptions)type;


-(void)setleftimg:(NSIndexPath*)indexpath andBOOL:(BOOL)singel andArr:(NSArray*)arr;

-(void)seticon:(UIImage*)img;
+ (int)getCellHeight:(HSChatMessage*)msg;
+ (int)BUBBLE_GAP;
+ (int)CELL_MARGIN;
@property(nonatomic,copy) void(^onUserClickBlock)();
@property(nonatomic,copy) void(^onMessageClickBlock)(HSChatMessage *chatMessage,UIView* sender);
@property(nonatomic,copy) void(^onMessageLongClickBlock)(HSChatMessage *chatMessage,SEL action,UIView* sender);
@end
