//
//  addFriendCell.h
//  PortSIP
//
//  Created by 今言网络 on 2017/12/14.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextImageView.h"
#import "History.h"
#import "addFriendModel.h"

@interface addFriendCell : UITableViewCell
{
    
    UIImageView * iconimageview;
    
    TextImageView *textimageview;
    
    
    UILabel * displayNameLab;
    
      UILabel * displaySTRLab;
    
    UIButton * declinebutton;
    
    UIButton * acceptbutton;
    
    UILabel *  editLabel;
    
    
}

@property(nonatomic,copy) void(^myDeclineBlock)(NSInteger tag);

@property(nonatomic,copy) void(^myAcceptBlock)(NSInteger tag);

-(void)initcell;


-(void)setcell:(History*)his andtag:(NSInteger)tag;


-(void)initHisCell;

-(void)setHisCell:(addFriendModel*)model;


@end
