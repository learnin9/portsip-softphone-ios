//
//  chatMoreView.h
//  PortGo
//
//  Created by 今言网络 on 2018/4/24.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXChatBoxItemView.h"

@class chatMoreView;

@protocol chatMoreViewDelegate <NSObject>

- (void)testdelete:(NSString*)teststr;

- (void)sendImage;
- (void)sendFile;

- (void)sendCustomCamera;


-(void)makeCall:(BOOL)video;

@end


@interface chatMoreView : UIView
@property (nonatomic, strong) id<chatMoreViewDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *items;


-(void)setUI;

@end
