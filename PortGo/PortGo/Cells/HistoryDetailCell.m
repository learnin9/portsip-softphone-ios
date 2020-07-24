//
//  HistoryDetailCell.m
//  PortGo
//
//  Created by 今言网络 on 2017/6/16.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HistoryDetailCell.h"

@implementation HistoryDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setHistoryDetailCellwith:(History *)record {
    
    NSString *timeStart = [[record getDetailsTimeStart] componentsSeparatedByString:@" "][1];
    
    switch (record.mMediaType) {
        case MediaType_Audio:
        {
            self.callType.image = [UIImage imageNamed:@"recent_calllist_details_audio_ico"];
            CGRect imageFrame = _callType.bounds;
            imageFrame.size.width = 15;
            imageFrame.size.height = 15;
            _callType.bounds = imageFrame;
            break;
        }
        case MediaType_Video:
            self.callType.image = [UIImage imageNamed:@"recent_calllist_details_video_ico"];
            break;
        case MediaType_AudioVideo:
        {
            self.callType.image = [UIImage imageNamed:@"recent_calllist_details_video_ico"];
            CGRect imageFrame = _callType.bounds;
            imageFrame.size.width = 20;
            imageFrame.size.height = 12;
            _callType.bounds = imageFrame;
            break;
        }
        default:
            break;
    }
    
    NSString *callState = nil;
    NSString *onlineState = nil;
    if(IS_EVENT_OUTGOING(record.mStatus)){
        if(IS_EVENT_FAILED(record.mStatus)){
            callState = NSLocalizedString(@"Call Out", @"Call Out");
            self.timeLabel.textColor = [UIColor redColor];
            onlineState = NSLocalizedString(@"Call Failed", @"Call Failed");
            self.callState.textColor = [UIColor redColor];
        }else{
            callState = NSLocalizedString(@"Call Out", @"Call Out");
            onlineState = [record getTimeDuration];
        }
    }else{
        if(IS_EVENT_FAILED(record.mStatus)){
            callState = NSLocalizedString(@"Call In", @"Call In");
            self.timeLabel.textColor = [UIColor redColor];
            onlineState = NSLocalizedString(@"Unconnect", @"Unconnect");
            self.callState.textColor = [UIColor redColor];
        }else{
            callState = NSLocalizedString(@"Call In", @"Call In");
            onlineState = [record getTimeDuration];
        }
    }
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@ %@",timeStart, callState];
    
    self.callState.text = onlineState;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
