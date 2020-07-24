//
//  addFriendCell.m
//  PortSIP
//
//  Created by 今言网络 on 2017/12/14.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "addFriendCell.h"

@implementation addFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)initcell{
    
    
    
    textimageview = [[TextImageView alloc] initWithFrame:CGRectMake(10, 3, 44, 44)];
    
    textimageview.textImageLabel.font = [UIFont fontWithName:@"Arial" size:22];
    
    textimageview.raduis = 20.0;
    

    
    [self addSubview:textimageview];
    
    
    
    displayNameLab = [[UILabel alloc]init];
    
    

    displayNameLab.textAlignment = NSTextAlignmentLeft;
    
    displayNameLab.frame = CGRectMake(65, 0, 150, 25);
    
    displayNameLab.font = [UIFont systemFontOfSize:16.f];
    
    [self addSubview:displayNameLab];
    
    
    
    displaySTRLab = [[UILabel alloc]init];
    
    
    displaySTRLab.text = @"hello";
    
    displaySTRLab.textAlignment = NSTextAlignmentLeft;
    
    displaySTRLab.frame = CGRectMake(65, 25, 100, 25);
    
    displaySTRLab.font = [UIFont systemFontOfSize:14.f];
    
    [self addSubview:displaySTRLab];
    
    
    
    declinebutton = [[UIButton alloc]init];
    
  
    declinebutton.backgroundColor = RGB(255, 59, 48);
    
    
    declinebutton.frame = CGRectMake(ScreenWid-140, 10, 60, 30);
    
    declinebutton.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [declinebutton setTitle:NSLocalizedString(@"Decline", @"Decline") forState:UIControlStateNormal];
    
    [declinebutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    declinebutton.layer.cornerRadius = 5;
    
    declinebutton.clipsToBounds = YES;
    
    
    [declinebutton addTarget:self action:@selector(decline:) forControlEvents:UIControlEventTouchUpInside];
    
    

    
    [self addSubview:declinebutton];
    
    
    acceptbutton = [[UIButton alloc]init];
    
  
    acceptbutton.backgroundColor = RGB(100, 175, 242);
    
    acceptbutton.frame = CGRectMake(ScreenWid-70, 10, 60, 30);
    
    [acceptbutton setTitle:NSLocalizedString(@"Accept", @"Accept") forState:UIControlStateNormal];
    
    
    acceptbutton.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [acceptbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    acceptbutton.layer.cornerRadius = 5;
    
    acceptbutton.clipsToBounds = YES;
    
    [acceptbutton addTarget:self action:@selector(accept:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:acceptbutton];
    
            
    
    
}


-(void)decline:(UIButton*)button{
    
    NSInteger tag = button.tag-258;
    
    
    if (_myDeclineBlock){
        
        self.myDeclineBlock(tag);
        
        
    }
    
    
    
}

-(void)accept:(UIButton*)button{
    
    NSInteger tag = button.tag-258-200;
    
    if (_myAcceptBlock){
        
        self.myAcceptBlock(tag);
        
        
    }
    
}

-(void)setcell:(History*)his andtag:(NSInteger)tag{
    
    declinebutton.tag = tag;
    
    acceptbutton.tag = tag+200;
    
    
    
    
    if (his.mRemotePartyDisplayName &&  ![his.mRemotePartyDisplayName isEqualToString:@""]) {
        
         displayNameLab.text = his.mRemotePartyDisplayName;
    }
    else
    {
        if ([his.mRemoteParty rangeOfString:@"@"].location == NSNotFound) {
            
            displayNameLab.text  = his.mRemoteParty;
            
            
        }else
        {
            NSArray *strs = [his.mRemoteParty componentsSeparatedByString:@"@"];
            
        
            
            NSString *first = strs[0];
            
            displayNameLab.text  = first;
            
        }
        
    }
    
  
    
    
    NSString * tempstr = [his.mRemoteParty substringFromIndex:his.mRemoteParty.length-1];
    
    if ([his.mRemoteParty containsString:@" "] && ![tempstr isEqualToString:@" "]) {
        
        NSArray *strs = [his.mRemoteParty componentsSeparatedByString:@" "];
        NSString *first = strs[0];
        NSString *last = strs[1];
        
        if (first.length<1) {
            
            first =@" ";
        }
        
        if (last.length <1) {
            
            last = @" ";
        }
        
        textimageview.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],[last substringToIndex:1]];
    } else {
        textimageview.textImageLabel.text = [his.mRemoteParty substringToIndex:2];
    }
    

}





-(void)initHisCell{
    
    textimageview = [[TextImageView alloc] initWithFrame:CGRectMake(10, 3, 44, 44)];
    
    textimageview.textImageLabel.font = [UIFont fontWithName:@"Arial" size:22];
    
    textimageview.raduis = 20.0;
    
    
    
    [self addSubview:textimageview];
    
    
    displayNameLab = [[UILabel alloc]init];
    
    displayNameLab.textAlignment = NSTextAlignmentLeft;
    
    displayNameLab.frame = CGRectMake(65, 0, 150, 50);
    
    displayNameLab.font = [UIFont systemFontOfSize:16.f];
    
    [self addSubview:displayNameLab];
    
    
    editLabel = [[UILabel alloc]init];
    
    editLabel.textAlignment = NSTextAlignmentRight;
    
    editLabel.frame = CGRectMake(ScreenWid-100, 10, 90, 30);
    
    editLabel.font = [UIFont systemFontOfSize:14.f];
    
    editLabel.textColor = RGB(178, 178, 178);
    

    [self addSubview:editLabel];
    
    
    
    
}

-(void)setHisCell:(addFriendModel*)model{
    
    NSString * tempstr = [model.mRemoteParty substringFromIndex:model.mRemoteParty.length-1];
    
    if ([model.mRemoteParty containsString:@" "] && ![tempstr isEqualToString:@" "]) {
        
        NSArray *strs = [model.mRemoteParty componentsSeparatedByString:@" "];
        NSString *first = strs[0];
        NSString *last = strs[1];
        
        if (first.length<1) {
            
            first =@" ";
        }
        
        if (last.length <1) {
            
            last = @" ";
        }
        
        textimageview.textImageLabel.text = [NSString stringWithFormat:@"%@%@",[first substringToIndex:1],[last substringToIndex:1]];
    } else {
        textimageview.textImageLabel.text = [model.mRemoteParty substringToIndex:2];
    }
    
    
    NSLog(@"model.mRemoteParty======%@",model.mRemoteParty);
    
    if ([model.mRemoteParty rangeOfString:@"@"].location == NSNotFound) {
        
        displayNameLab.text  = model.mRemoteParty;
        
        
    }else
    {
        NSArray *strs = [model.mRemoteParty componentsSeparatedByString:@"@"];
        
        
        
        NSString *first = strs[0];
        
        displayNameLab.text  = first;
        
    }
    NSLog(@"model.isedit===%d",model.isedit);
    
    if (model.isedit) {
        
        editLabel.text = NSLocalizedString(@"Accepted", @"Accepted");
        
        
    }
    else
    {
           editLabel.text = NSLocalizedString(@"Refused", @"Refused");
        
    }
    
    
    
    
    
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
