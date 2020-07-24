//
//  PSMarklist.h
//  PortGo
//
//  Created by 今言网络 on 2017/7/18.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSMarklist : UIView

@property (nonatomic, strong) UIImage *tagDeleteimage;

@property (nonatomic, assign) CGFloat tagMargin;

@property (nonatomic, strong) UIColor *tagColor;
@property (nonatomic, strong) UIColor *tagBackgroundColor;
@property (nonatomic, strong) UIImage *tagBackgroundImage;
@property (nonatomic, assign) UIFont *tagFont;
@property (nonatomic, assign) CGFloat tagButtonMargin;
@property (nonatomic, assign) CGFloat tagCornerRadius;
@property (nonatomic, assign) CGFloat tagListH;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong, readonly) NSMutableArray *tagArray;
@property (nonatomic, assign) BOOL isFitTagListH;
@property (nonatomic, assign) BOOL isSort;
@property (nonatomic, assign) CGFloat scaleTagInSort;
@property (nonatomic, assign) Class tagClass;

@property (nonatomic, assign) CGSize tagSize;

@property (nonatomic, assign) NSInteger tagListCols;


- (void)addTag:(NSString *)tagStr;

- (void)addTags:(NSArray *)tagStrs;
- (void)deleteTag:(NSString *)tagStr;
@property (nonatomic, strong) void(^clickTagBlock)(NSString *tag);

@end
