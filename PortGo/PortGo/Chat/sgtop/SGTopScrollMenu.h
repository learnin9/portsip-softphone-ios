//
//  SGTopScrollMenu.h
//  11111
//
//  Created by jianduan_li on 16/10/22.
//  Copyright © 2016年 jianduan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SGTopScrollMenu;

@protocol SGTopScrollMenuDelegate <NSObject>
// delegate 方法
@optional
- (void)SGTopScrollMenu:(SGTopScrollMenu *)topScrollMenu didSelectTitleAtIndex:(NSInteger)index;

-(void)setindexx:(NSInteger)index;

@end

@interface SGTopScrollMenu : UIScrollView

/** 滚动标题数组 */
@property (nonatomic, strong) NSArray *scrollTitleArr;
/** 静止标题数组 */
@property (nonatomic, strong) NSArray *staticTitleArr;
/** 存入所有Label */
@property (nonatomic, strong) NSMutableArray *allTitleLabel;
@property (nonatomic, weak) id<SGTopScrollMenuDelegate> topScrollMenuDelegate;
@property (nonatomic) NSInteger selectIndex;

/** 类方法 */
+ (instancetype)topScrollMenuWithFrame:(CGRect)frame;

#pragma mark - - - 给外界ScrollView提供的方法以及自身的方法实现
/** 滚动标题选中颜色改变以及指示器位置变化 */
- (void)scrollTitleLabelSelecteded:(UILabel *)label;
/** 滚动标题选中居中 */
- (void)scrollTitleLabelSelectededCenter:(UILabel *)centerLabel;

/** 静止标题选中颜色改变以及指示器位置变化 */
- (void)staticTitleLabelSelecteded:(UILabel *)label;


-(void)setlab:(NSInteger)index22;


@end


