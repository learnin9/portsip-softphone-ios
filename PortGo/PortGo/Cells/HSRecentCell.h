//
//  HSRecentCell.h
//  PortGo
//
//  Created by MrLee on 14-9-28.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class History;

@interface HSRecentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property(readwrite,retain)NSString* remoteParty;
@property (nonatomic, strong) History *history;
@end
