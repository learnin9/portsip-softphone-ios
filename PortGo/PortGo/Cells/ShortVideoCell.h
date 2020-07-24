//
//  ShortVideoCell.h
//  PortSIP
//
//  Created by 今言网络 on 2018/8/27.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSChatMessage.h"

#import "TextImageView.h"

#import "Contact.h"

@interface ShortVideoCell : UITableViewCell
{
    
    UIImageView * cellimageview;
    UIImageView * statusview;
    UIImageView * cellimageview3;
    BOOL  ifnosingle;
}

@property  NSString* teststr;
@property NSURL * testURL;
@property  UIImage * testimge;
@property UIImage * tupianimg;

@property (strong, nonatomic) UIImage *iocn;
@property (nonatomic, strong) UIImageView *contactIcon;
@property (nonatomic, strong) TextImageView *textImage;
@property  Contact * mycontact;
@property  int  luyinlength;
@property  BOOL  isListen;
@property  NSInteger historyID;

@property (nonatomic, strong) HSChatMessage *chatMessage;


@property  NSString* messageTYPE;  //表示附件类型

-(void)setCellImage:(UIImage*)cellimage andTYPE:(NSString* )type;
-(void)setCellImage2:(NSURL*)cellimageurl andTYPE:(NSString* )type;
-(void)setCellImage3:(NSURL*)cellRecordurl andTYPE:(NSString* )type;

@property(nonatomic,copy) void(^imageBlock)(UIImageView * temp);
@property(nonatomic,copy) void(^RecordBlock)();
@property(nonatomic,copy) void(^shortVideoBlock)();

-(void)loadContactIconWhichside:(int)side;
-(void)setlengthLab:(int)length;

@end
