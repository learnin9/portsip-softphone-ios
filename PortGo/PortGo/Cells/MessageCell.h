//
//  MessageCell.h
//  PortGo
//
//  Created by Joe Lepple on 4/13/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"
#import "TextImageView.h"
#import "HSChatSession.h"

#undef kMessageCellIdentifier
#define kMessageCellIdentifier	@"MessageCell"

@interface MessageCell : UITableViewCell{
    int       mHistoryID;
    int mMediaType;
}

@property int mHistoryID;
@property (weak, nonatomic) IBOutlet UIImageView *imageHeadView;
@property (retain, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (retain, nonatomic) IBOutlet UILabel *labelDate;
@property (retain, nonatomic) IBOutlet UILabel *labelContent;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic, strong) TextImageView *textImage;
@property (weak, nonatomic) IBOutlet UIImageView *nextImageArrow;
@property (nonatomic, strong) UIView *cellSeperatorView;
@property(nonatomic,copy) void(^RedDelegate)(NSInteger tag);

- (void)setChatSession: (HSChatSession*)chatSession;
- (void)setChatHistory:(History*)chatHistory;
@end
