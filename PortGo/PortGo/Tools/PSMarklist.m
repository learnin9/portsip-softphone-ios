//
//  PSMarklist.m
//  PortGo
//
//  Created by 今言网络 on 2017/7/18.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "PSMarklist.h"
#import "PSMarkButton.h"

CGFloat const imageViewWH = 20;

@interface PSMarklist ()
{
    NSMutableArray *_tagArray;
}
@property (nonatomic, weak) UICollectionView *tagListView;
@property (nonatomic, strong) NSMutableDictionary *tags;
@property (nonatomic, strong) NSMutableArray *tagButtons;

@property (nonatomic, assign) CGRect moveFinalRect;
@property (nonatomic, assign) CGPoint oriCenter;
@end

@implementation PSMarklist

- (NSMutableArray *)tagArray
{
    if (_tagArray == nil) {
        _tagArray = [NSMutableArray array];
    }
    return _tagArray;
}
- (NSMutableArray *)tagButtons
{
    if (_tagButtons == nil) {
        _tagButtons = [NSMutableArray array];
    }
    return _tagButtons;
}

- (NSMutableDictionary *)tags
{
    if (_tags == nil) {
        _tags = [NSMutableDictionary dictionary];
    }
    return _tags;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

#pragma mark
- (void)setup
{
    _tagMargin = 10;
    _tagColor = [UIColor redColor];
    _tagButtonMargin = 5;
    _tagCornerRadius = 5;
    _borderWidth = 0;
    _borderColor = _tagColor;
    _tagListCols = 4;
    _scaleTagInSort = 1;
    _isFitTagListH = YES;
    _tagFont = [UIFont systemFontOfSize:13];
    self.clipsToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _tagListView.frame = self.bounds;
}

- (void)setScaleTagInSort:(CGFloat)scaleTagInSort
{
    if (_scaleTagInSort < 1) {
        @throw [NSException exceptionWithName:@"YZError" reason:@"(scaleTagInSort)缩放比例必须大于1" userInfo:nil];
    }
    _scaleTagInSort = scaleTagInSort;
}

- (CGFloat)tagListH
{
    if (self.tagButtons.count <= 0) return 0;
    return CGRectGetMaxY([self.tagButtons.lastObject frame]) + _tagMargin;
}

#pragma mark

- (void)addTags:(NSArray *)tagStrs
{
    if (self.frame.size.width == 0) {
        @throw [NSException exceptionWithName:@"YZError" reason:@"NULL Frame" userInfo:nil];
    }
    
    for (NSString *tagStr in tagStrs) {
        [self addTag:tagStr];
    }
}

- (void)addTag:(NSString *)tagStr
{
    Class tagClass = _tagClass?_tagClass : [PSMarkButton class];
    
    
    PSMarkButton *tagButton = [tagClass buttonWithType:UIButtonTypeCustom];
    if (_tagClass == nil) {
        tagButton.margin = _tagButtonMargin;
    }
    tagButton.layer.cornerRadius = _tagCornerRadius;
    tagButton.layer.borderWidth = _borderWidth;
    tagButton.layer.borderColor = _borderColor.CGColor;
    tagButton.clipsToBounds = YES;
    tagButton.tag = self.tagButtons.count;
    [tagButton setImage:_tagDeleteimage forState:UIControlStateNormal];
    [tagButton setTitle:tagStr forState:UIControlStateNormal];
    [tagButton setTitleColor:_tagColor forState:UIControlStateNormal];
    [tagButton setBackgroundColor:_tagBackgroundColor];
    [tagButton setBackgroundImage:_tagBackgroundImage forState:UIControlStateNormal];
    tagButton.titleLabel.font = _tagFont;
    [tagButton addTarget:self action:@selector(clickTag:) forControlEvents:UIControlEventTouchUpInside];
    if (_isSort) {
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [tagButton addGestureRecognizer:pan];
    }
    [self addSubview:tagButton];
    
    [self.tagButtons addObject:tagButton];
    [self.tags setObject:tagButton forKey:tagStr];
    [self.tagArray addObject:tagStr];
    
    [self updateTagButtonFrame:tagButton.tag extreMargin:YES];
    
    if (_isFitTagListH) {
        CGRect frame = self.frame;
        frame.size.height = self.tagListH;
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = frame;
        }];
    }
}

- (void)clickTag:(UIButton *)button
{
    
    if (_clickTagBlock) {
        _clickTagBlock(button.currentTitle);
    }
}

- (void)pan:(UIPanGestureRecognizer *)pan
{
    
    CGPoint transP = [pan translationInView:self];
    
    UIButton *tagButton = (UIButton *)pan.view;
    
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _oriCenter = tagButton.center;
        [UIView animateWithDuration:-.25 animations:^{
            tagButton.transform = CGAffineTransformMakeScale(_scaleTagInSort, _scaleTagInSort);
        }];
        [self addSubview:tagButton];
    }
    
    CGPoint center = tagButton.center;
    center.x += transP.x;
    center.y += transP.y;
    tagButton.center = center;
    
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        
        UIButton *otherButton = [self buttonCenterInButtons:tagButton];
        
        if (otherButton) {
            
            NSInteger i = otherButton.tag;
            
            
            NSInteger curI = tagButton.tag;
            
            _moveFinalRect = otherButton.frame;
            
            [self.tagButtons removeObject:tagButton];
            [self.tagButtons insertObject:tagButton atIndex:i];
            
            [self.tagArray removeObject:tagButton.currentTitle];
            [self.tagArray insertObject:tagButton.currentTitle atIndex:i];
            
            [self updateTag];
            
            if (curI > i) {
                [UIView animateWithDuration:0.25 animations:^{
                    [self updateLaterTagButtonFrame:i + 1];
                }];
                
            } else {
                [UIView animateWithDuration:0.25 animations:^{
                    [self updateBeforeTagButtonFrame:i];
                }];
            }
        }
        
    }
    
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.25 animations:^{
            tagButton.transform = CGAffineTransformIdentity;
            if (_moveFinalRect.size.width <= 0) {
                tagButton.center = _oriCenter;
            } else {
                tagButton.frame = _moveFinalRect;
            }
        } completion:^(BOOL finished) {
            _moveFinalRect = CGRectZero;
        }];
        
    }
    
    [pan setTranslation:CGPointZero inView:self];
}

- (UIButton *)buttonCenterInButtons:(UIButton *)curButton
{
    for (UIButton *button in self.tagButtons) {
        if (curButton == button) continue;
        if (CGRectContainsPoint(button.frame, curButton.center)) {
            return button;
        }
    }
    return nil;
}

- (void)deleteTag:(NSString *)tagStr
{
    PSMarkButton *button = self.tags[tagStr];
    [button removeFromSuperview];
    [self.tagButtons removeObject:button];
    [self.tags removeObjectForKey:tagStr];
    [self.tagArray removeObject:tagStr];
    [self updateTag];
    
    
    [UIView animateWithDuration:0.25 animations:^{
        [self updateLaterTagButtonFrame:button.tag];
    }];
    
    
    if (_isFitTagListH) {
        CGRect frame = self.frame;
        frame.size.height = self.tagListH;
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = frame;
        }];
    }
    
}

- (void)updateTag
{
    NSInteger count = self.tagButtons.count;
    for (int i = 0; i < count; i++) {
        UIButton *tagButton = self.tagButtons[i];
        tagButton.tag = i;
    }
}


- (void)updateBeforeTagButtonFrame:(NSInteger)beforeI
{
    for (int i = 0; i < beforeI; i++) {
        
        [self updateTagButtonFrame:i extreMargin:NO];
    }
}

- (void)updateLaterTagButtonFrame:(NSInteger)laterI
{
    NSInteger count = self.tagButtons.count;
    
    for (NSInteger i = laterI; i < count; i++) {
        [self updateTagButtonFrame:i extreMargin:NO];
    }
}

- (void)updateTagButtonFrame:(NSInteger)i extreMargin:(BOOL)extreMargin
{
    NSInteger preI = i - 1;
    UIButton *preButton;
    
    if (preI >= 0) {
        preButton = self.tagButtons[preI];
    }
    
    PSMarkButton *tagButton = self.tagButtons[i];
    
    if (_tagSize.width == 0) {
        [self setupTagButtonCustomFrame:tagButton preButton:preButton extreMargin:extreMargin];
    } else {
        
        [self setupTagButtonRegularFrame:tagButton];
    }
    
    
}


- (void)setupTagButtonRegularFrame:(UIButton *)tagButton
{
    
    NSInteger i = tagButton.tag;
    NSInteger col = i % _tagListCols;
    NSInteger row = i / _tagListCols;
    CGFloat btnW = _tagSize.width;
    CGFloat btnH = _tagSize.height;
    NSInteger margin = (self.bounds.size.width - _tagListCols * btnW - 2 * _tagMargin) / (_tagListCols - 1);
    CGFloat btnX = _tagMargin + col * (btnW + margin);;
    CGFloat btnY = _tagMargin + row * (btnH + margin);
    tagButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
}


- (void)setupTagButtonCustomFrame:(UIButton *)tagButton preButton:(UIButton *)preButton extreMargin:(BOOL)extreMargin
{
    
    CGFloat btnX = CGRectGetMaxX(preButton.frame) + _tagMargin;
    
    CGFloat btnY = preButton? preButton.frame.origin.y : _tagMargin;
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGFloat titleW = [tagButton.titleLabel.text sizeWithFont:_tagFont].width;
    CGFloat titleH = [tagButton.titleLabel.text sizeWithFont:_tagFont].height;
    
#pragma clang diagnostic pop
    
    CGFloat btnW = extreMargin?titleW + 2 * _tagButtonMargin : tagButton.bounds.size.width ;
    if (_tagDeleteimage && extreMargin == YES) {
        btnW += imageViewWH;
        btnW += _tagButtonMargin;
    }
    
    
    CGFloat btnH = extreMargin? titleH + 2 * _tagButtonMargin:tagButton.bounds.size.height;
    if (_tagDeleteimage && extreMargin == YES) {
        CGFloat height = imageViewWH > titleH ? imageViewWH : titleH;
        btnH = height + 2 * _tagButtonMargin;
    }
    
    
    CGFloat rightWidth = self.bounds.size.width - btnX;
    
    if (rightWidth < btnW) {
        btnX = _tagMargin;
        btnY = CGRectGetMaxY(preButton.frame) + _tagMargin;
    }
    
    tagButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
}

@end
