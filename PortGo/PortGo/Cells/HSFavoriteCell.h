//
//  HSFavoriteCell.h
//  PortGo
//
//  Created by portsip on 16/11/23.
//  Copyright © 2016年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Favorite;

@interface HSFavoriteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *displayName;
@property (weak, nonatomic) IBOutlet UILabel *typeName;
@property (weak, nonatomic) IBOutlet UIImage *detailMessage;
@property(readwrite,retain)NSString* remoteParty;
@property (nonatomic, strong) Favorite *mFavorite;

- (void)setFavorite:(Favorite *)favorite;
@end
