//
//  SGTopScrollMenu.m
//  11111
//
//  Created by jianduan_li on 16/10/22.
//  Copyright © 2016年 jianduan. All rights reserved.
//

#import "SGTopScrollMenu.h"
#import "UIView+SGExtension.h"

#define labelFontOfSize [UIFont systemFontOfSize:17]
#define SG_screenWidth [UIScreen mainScreen].bounds.size.width
#define selectedTitleAndIndicatorViewColor [UIColor colorWithRed:0.24 green:0.46 blue:0.91 alpha:0.8]

@interface SGTopScrollMenu ()
/** 滚动标题Label */
@property (nonatomic, strong) UILabel *scrollTitleLabel;
/** 静止标题Label */
@property (nonatomic, strong) UILabel *staticTitleLabel;
/** 选中标题时的Label */
@property (nonatomic, strong) UILabel *selectedLabel;
/** 指示器 */
@property (nonatomic, strong) UIView *indicatorView;

@property NSMutableArray *labArr;



@end


@implementation SGTopScrollMenu

/** label之间的间距 */
static CGFloat const labelMargin = 15;
/** 指示器的高度 */
static CGFloat const indicatorHeight = 2;

- (NSMutableArray *)allTitleLabel {
    if (_allTitleLabel == nil) {
        _allTitleLabel = [NSMutableArray array];
    }
    return _allTitleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = YES;
//        [UIColor blackColor];
        
        _labArr = [[NSMutableArray alloc]init];
        
        
    }
    return self;
}

+ (instancetype)topScrollMenuWithFrame:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}


/**
 *  计算文字尺寸
 *
 *  @param text    需要计算尺寸的文字
 *  @param font    文字的字体
 *  @param maxSize 文字的最大尺寸
 */
- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}



-(void)setlab:(NSInteger)index22{

    
    // 0.获取选中的label
    UILabel *selLabel = [_allTitleLabel objectAtIndex:index22];
    
    // 1.标题颜色变成红色,设置高亮状态下的颜色， 以及指示器位置
    [self scrollTitleLabelSelecteded:selLabel];
    
    // 2.让选中的标题居中 (当contentSize 大于self的宽度才会生效)
    [self scrollTitleLabelSelectededCenter:selLabel];
    
    // 3.代理方法实现
    _selectIndex = selLabel.tag-1008;
    NSInteger index = selLabel.tag-1008;
    
  //  NSLog(@"_selectIndex=x=%d",selLabel.tag-1008);
    
    
    if ( [self.topScrollMenuDelegate respondsToSelector:@selector(setindexx:)]) {
        
        [self.topScrollMenuDelegate setindexx:selLabel.tag-1008];
        
        
        
    }
    
    
    if ([self.topScrollMenuDelegate respondsToSelector:@selector(SGTopScrollMenu:didSelectTitleAtIndex:)]) {
        [self.topScrollMenuDelegate SGTopScrollMenu:self didSelectTitleAtIndex:index];
    }

}


#pragma mark - - - 重写滚动标题数组的setter方法
- (void)setScrollTitleArr:(NSArray *)scrollTitleArr {
    _scrollTitleArr = scrollTitleArr;
    
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    CGFloat labelH = self.frame.size.height - indicatorHeight;
    
    for (NSUInteger i = 0; i < self.scrollTitleArr.count; i++) {
        /** 创建滚动时的标题Label */
        self.scrollTitleLabel = [[UILabel alloc] init];
        _scrollTitleLabel.userInteractionEnabled = YES;
        _scrollTitleLabel.text = self.scrollTitleArr[i];
        _scrollTitleLabel.textColor = [UIColor grayColor];
        _scrollTitleLabel.textAlignment = NSTextAlignmentCenter;
       // _scrollTitleLabel.tag = i;

        // 设置高亮文字颜色
        _scrollTitleLabel.highlightedTextColor = selectedTitleAndIndicatorViewColor;
        // 计算内容的Size
        CGSize labelSize = [self sizeWithText:_scrollTitleLabel.text font:labelFontOfSize maxSize:CGSizeMake(MAXFLOAT, labelH)];
        // 计算内容的宽度
        CGFloat labelW = labelSize.width + 2 * labelMargin;
        
        _scrollTitleLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
        
        // 计算每个label的X值
        labelX = labelX + labelW;
        
        // 添加到titleLabels数组
        
        
        
        
        _scrollTitleLabel.tag = 1008+i;
        
        
//        NSLog(@"_scrollTitleLabel.tag===%d",_scrollTitleLabel.tag);
        
        [self.allTitleLabel addObject:_scrollTitleLabel];
        
        
        
        
        // 添加点按手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTitleClick:)];
        
        
        [_scrollTitleLabel addGestureRecognizer:tap];
        
        // 默认选中第0个label
        if (i == 0) {
            [self scrollTitleClick:tap];
        }

        [self addSubview:_scrollTitleLabel];
    }
    
    // 计算scrollView的宽度
    CGFloat scrollViewWidth = CGRectGetMaxX(self.subviews.lastObject.frame);
    self.contentSize = CGSizeMake(scrollViewWidth, self.frame.size.height);
    
    // 取出第一个子控件
    UILabel *firstLabel = self.subviews.firstObject;
    
    // 添加指示器
    self.indicatorView = [[UIView alloc] init];
    _indicatorView.backgroundColor = selectedTitleAndIndicatorViewColor;
    _indicatorView.SG_height = indicatorHeight;
    _indicatorView.SG_y = self.frame.size.height - indicatorHeight-10;
    [self addSubview:_indicatorView];
    
    
    // 指示器默认在第一个选中位置
    // 计算TitleLabel内容的Size
    CGSize labelSize = [self sizeWithText:firstLabel.text font:labelFontOfSize maxSize:CGSizeMake(MAXFLOAT, labelH)];
    _indicatorView.SG_width = labelSize.width;
    _indicatorView.SG_centerX = firstLabel.SG_centerX;
}

/** scrollTitleClick的点击事件 */
- (void)scrollTitleClick:(UITapGestureRecognizer *)tap {
    // 0.获取选中的label
    UILabel *selLabel = (UILabel *)tap.view;
    
    // 1.标题颜色变成红色,设置高亮状态下的颜色， 以及指示器位置
    [self scrollTitleLabelSelecteded:selLabel];
    
    // 2.让选中的标题居中 (当contentSize 大于self的宽度才会生效)
    [self scrollTitleLabelSelectededCenter:selLabel];
    
    // 3.代理方法实现
    _selectIndex = selLabel.tag-1008;
    NSInteger index = selLabel.tag-1008;
    
  //  NSLog(@"_selectIndex=x=%d",selLabel.tag-1008);
    
    
    if ( [self.topScrollMenuDelegate respondsToSelector:@selector(setindexx:)]) {
        
        [self.topScrollMenuDelegate setindexx:selLabel.tag-1008];
        
        
        
    }
    
    
    if ([self.topScrollMenuDelegate respondsToSelector:@selector(SGTopScrollMenu:didSelectTitleAtIndex:)]) {
        [self.topScrollMenuDelegate SGTopScrollMenu:self didSelectTitleAtIndex:index];
    }
}

/** 滚动标题选中颜色改变以及指示器位置变化 */
- (void)scrollTitleLabelSelecteded:(UILabel *)label {

    // 取消高亮
    _selectedLabel.highlighted = NO;
    
    // 颜色恢复
    _selectedLabel.textColor = [UIColor grayColor];
    
    // 高亮
    label.highlighted = YES;
    
    _selectedLabel = label;
    _selectIndex = label.tag;
    // 改变指示器位置
    [UIView animateWithDuration:0.20 animations:^{
        self.indicatorView.SG_width = label.SG_width - 2 * labelMargin;
        self.indicatorView.SG_centerX = label.SG_centerX;
    }];
}

/** 滚动标题选中居中 */
- (void)scrollTitleLabelSelectededCenter:(UILabel *)centerLabel {
    
    if  (_scrollTitleArr .count  >2){
    
    
    
    
    
    // 计算偏移量
    CGFloat offsetX = centerLabel.center.x - SG_screenWidth * 0.5;
    
    if (offsetX < 0) offsetX = 0;
    
    // 获取最大滚动范围
    CGFloat maxOffsetX = self.contentSize.width - SG_screenWidth;
    
    if (offsetX > maxOffsetX) offsetX = maxOffsetX;
    
    // 滚动标题滚动条
    [self setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
    
    
}
}

#pragma mark - - - 重写静止标题数组的setter方法
- (void)setStaticTitleArr:(NSArray *)staticTitleArr {
    _staticTitleArr = staticTitleArr;
    
    // 计算scrollView的宽度
    CGFloat scrollViewWidth = self.frame.size.width;
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    CGFloat labelW = scrollViewWidth / self.staticTitleArr.count;
    CGFloat labelH = self.frame.size.height - indicatorHeight;
    
    for (NSInteger j = 0; j < self.staticTitleArr.count; j++) {
        // 创建静止时的标题Label
        self.staticTitleLabel = [[UILabel alloc] init];
        _staticTitleLabel.userInteractionEnabled = YES;
        _staticTitleLabel.text = self.staticTitleArr[j];
        _staticTitleLabel.textAlignment = NSTextAlignmentCenter;
        _staticTitleLabel.tag = j;
        
        // 设置高亮文字颜色
        _staticTitleLabel.highlightedTextColor = selectedTitleAndIndicatorViewColor;
        
        // 计算staticTitleLabel的x值
        labelX = j * labelW;
        
        _staticTitleLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
        
        // 添加到titleLabels数组
        [self.allTitleLabel addObject:_staticTitleLabel];
        
        // 添加点按手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(staticTitleClick:)];
        [_staticTitleLabel addGestureRecognizer:tap];
        
        // 默认选中第0个label
        if (j == 0) {
            [self staticTitleClick:tap];
        }
        
        [self addSubview:_staticTitleLabel];
    }

    // 取出第一个子控件
    UILabel *firstLabel = self.subviews.firstObject;
    
    // 添加指示器
    self.indicatorView = [[UIView alloc] init];
    _indicatorView.backgroundColor = selectedTitleAndIndicatorViewColor;
    _indicatorView.SG_height = indicatorHeight;
    _indicatorView.SG_y = self.frame.size.height - indicatorHeight;
    [self addSubview:_indicatorView];
    
    
    // 指示器默认在第一个选中位置
    // 计算TitleLabel内容的Size
    CGSize labelSize = [self sizeWithText:firstLabel.text font:labelFontOfSize maxSize:CGSizeMake(MAXFLOAT, labelH)];
    _indicatorView.SG_width = labelSize.width;
    _indicatorView.SG_centerX = firstLabel.SG_centerX;
}

/** staticTitleClick的点击事件 */
- (void)staticTitleClick:(UITapGestureRecognizer *)tap {
    // 0.获取选中的label
    UILabel *selLabel = (UILabel *)tap.view;
    
    // 1.标题颜色变成红色,设置高亮状态下的颜色， 以及指示器位置
    [self staticTitleLabelSelecteded:selLabel];
    
    // 2.代理方法实现
    NSInteger index = selLabel.tag;
    if ([self.topScrollMenuDelegate respondsToSelector:@selector(SGTopScrollMenu:didSelectTitleAtIndex:)]) {
        [self.topScrollMenuDelegate SGTopScrollMenu:self didSelectTitleAtIndex:index];
    }
}
/** 静止标题选中颜色改变以及指示器位置变化 */
- (void)staticTitleLabelSelecteded:(UILabel *)label {
    // 取消高亮
    _selectedLabel.highlighted = NO;
    
    // 颜色恢复
    _selectedLabel.textColor = [UIColor grayColor];
    
    // 高亮
    label.highlighted = YES;
    
    _selectedLabel = label;
    
    // 改变指示器位置
    [UIView animateWithDuration:0.20 animations:^{
        // 计算内容的Size
        CGSize labelSize = [self sizeWithText:_selectedLabel.text font:labelFontOfSize maxSize:CGSizeMake(MAXFLOAT, self.frame.size.height - indicatorHeight)];
        self.indicatorView.SG_width = labelSize.width;
        self.indicatorView.SG_centerX = label.SG_centerX;
    }];
}



@end


