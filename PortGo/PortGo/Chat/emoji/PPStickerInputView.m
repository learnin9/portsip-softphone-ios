//
//  PPStickerTextView.m
//  PPStickerKeyboard
//
//  Created by Vernon on 2018/1/17.
//  Copyright © 2018年 Vernon. All rights reserved.
//

#import "PPStickerInputView.h"
#import "PPStickerKeyboard.h"
#import "PPStickerTextView.h"
#import "PPUtil.h"
#import "UIColor_Hex.h"
#import "chatMoreView.h"
#import "recordingView.h"

/**
 *  枚举的一种定义形式,和基本的枚举定义类型一样，只是结构更加清晰点；
 */
typedef NS_ENUM(NSInteger, ZXChatBoxStatus) {
    /**
     *  无状态
     */
    TLChatBoxStatusNothing,
    /**
     *  声音
     */
    TLChatBoxStatusShowVoice,
    /**
     *  表情
     */
    TLChatBoxStatusShowFace,
    /**
     *  更多
     */
    TLChatBoxStatusShowMore,
    /**
     *  键盘
     */
    TLChatBoxStatusShowKeyboard,
    
};
static CGFloat const PPStickerTextViewHeight = 50.0;

static CGFloat const PPStickerTextViewTextViewTopMargin = 10.0;
static CGFloat const PPStickerTextViewTextViewUnfocusLeftRightPadding = 5.0;
static CGFloat const PPStickerTextViewTextViewLeftRightPadding = 16.0;
static CGFloat const PPStickerTextViewTextViewBottomMargin = 10.0;
static NSUInteger const PPStickerTextViewMaxLineCount = 6;
static NSUInteger const PPStickerTextViewMinLineCount = 3;
static CGFloat const PPStickerTextViewLineSpacing = 3.0;
static CGFloat const PPStickerTextViewFontSize = 16.0;

static CGFloat const PPStickerTextViewEmojiToggleLength = 48.0;
static CGFloat const PPStickerTextViewToggleButtonLength = 24.0;

@interface PPStickerInputView () <UITextViewDelegate, PPStickerKeyboardDelegate>

@property (nonatomic, strong) PPStickerTextView *textView;
@property (nonatomic, strong) UIView *separatedLine;
@property (nonatomic, strong) PPButton *emojiToggleButton;
@property (nonatomic, strong) PPStickerKeyboard *stickerKeyboard;
@property (nonatomic, strong) UIView *bottomBGView;     // 消除语音键盘的空隙

@property (nonatomic, strong) PPButton *voicebutton;

@property (nonatomic, strong) PPButton *addbutton;

@property (nonatomic, strong) UIButton *talkbutton;

@property  (nonatomic, strong) chatMoreView * chatBoxMoreView;

@property (nonatomic ,strong) recordingView*  recordingview;



@property (nonatomic, assign, readwrite) PPKeyboardType keyboardType;
@property (nonatomic, assign) BOOL keepsPreModeTextViewWillEdited;

@property (nonatomic, assign) bool fileMessage;
@property (nonatomic, assign) ZXChatBoxStatus status;




@end

@implementation PPStickerInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        self.exclusiveTouch = YES;
        //   self.backgroundColor = [UIColor whiteColor];
        
        _keyboardType = PPKeyboardTypeSystem;
        _keepsPreModeTextViewWillEdited = YES;

        [self addSubview:self.textView];
        [self addSubview:self.separatedLine];
        
        [self addSubview:self.voicebutton];
        [self addSubview:self.addbutton];
        
        
        [self addSubview:self.emojiToggleButton];
        
        
        [self addSubview:self.talkbutton];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor pp_colorWithRGBString:@"#D2D2D2"] setStroke];
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, PPOnePixelToPoint());
    CGContextMoveToPoint(context, 0, PPOnePixelToPoint() / 2);
    CGContextAddLineToPoint(context, CGRectGetMaxX(self.bounds), PPOnePixelToPoint() / 2);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    int gap = 8,left,width;
    if(self.fileMessage){
//        self.textView.frame = [self frameTextView];
        self.separatedLine.frame = [self frameSeparatedLine];
        self.emojiToggleButton.frame = [self frameEmojiToggleButton];
        self.voicebutton.frame = [self frameVoiceButton];
        self.addbutton.frame = [self frameAddButton];
        
        left =self.voicebutton.frame.origin.x+self.voicebutton.frame.size.width+gap;
        width =self.emojiToggleButton.frame.origin.x-left - gap;
        
        self.voicebutton.hidden = false;
        self.addbutton.hidden = false;
        
    }else{
        
        self.separatedLine.frame = [self frameSeparatedLine];
        self.emojiToggleButton.frame = [self frameAddButton];//[self frameEmojiToggleButton];
        self.voicebutton.frame = [self frameVoiceButton];
        self.addbutton.frame = [self frameAddButton];
        
        left =self.voicebutton.frame.origin.x;
        width =self.emojiToggleButton.frame.origin.x-left - gap;
        
        self.voicebutton.hidden = true;
        self.addbutton.hidden = true;
        self.talkbutton.hidden = true;
    }
    self.textView.frame = CGRectMake(left, 6, width, 38);
    self.talkbutton.frame = self.textView.frame;
    //    } else {
    //        self.separatedLine.frame = CGRectZero;
    //        self.emojiToggleButton.frame = CGRectZero;
    //    }
    
    [self refreshTextUI];
    
    [self traitCollectionDidChange:self.traitCollection];
}

- (CGFloat)heightThatFits
{
    
    return PPStickerTextViewHeight;
    
    if (self.keepsPreModeTextViewWillEdited) {
        return PPStickerTextViewHeight;
    } else {
        CGFloat textViewHeight = [self.textView.layoutManager usedRectForTextContainer:self.textView.textContainer].size.height;
        CGFloat minHeight = [self heightWithLine:PPStickerTextViewMinLineCount];
        CGFloat maxHeight = [self heightWithLine:PPStickerTextViewMaxLineCount];
        CGFloat calculateHeight = MIN(maxHeight, MAX(minHeight, textViewHeight));
        CGFloat height = PPStickerTextViewTextViewTopMargin + calculateHeight + PPStickerTextViewTextViewBottomMargin + PPStickerTextViewEmojiToggleLength;
        return height;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(size.width, [self heightThatFits]);
}

- (void)sizeToFit
{
    CGSize size = [self sizeThatFits:self.bounds.size];
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame) - size.height, size.width, size.height);
}

#pragma mark - public method

- (void)clearText
{
    self.textView.text = nil;
    self.textView.font = [UIFont systemFontOfSize:PPStickerTextViewFontSize];
    [self sizeToFit];
}

- (NSString *)plainText
{
    return [self.textView.attributedText pp_plainTextForRange:NSMakeRange(0, self.textView.attributedText.length)];
}

- (void)changeKeyboardTo:(PPKeyboardType)toType
{
    if (self.keyboardType == toType) {
        return;
    }
    
    switch (toType) {
        case PPKeyboardTypeNone:
            [self.emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
            [self.emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
                  
            self.textView.inputView = nil;
            break;
        case PPKeyboardTypeSystem:
            [self.emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
            [self.emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
            
            
            self.textView.inputView = nil;                          // 切换到系统键盘
            [self.textView reloadInputViews];                       // 调用reloadInputViews方法会立刻进行键盘的切换
            break;
        case PPKeyboardTypeSticker:
            
            [self.emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
            [self.emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
            
            
            self.textView.inputView = self.stickerKeyboard;         // 切换到自定义的表情键盘
            [self.textView reloadInputViews];
            
            [self.textView becomeFirstResponder];
            
            
            break;
        default:
            break;
    }
    
    self.keyboardType = toType;
}

#pragma mark - getter / setter

- (PPStickerTextView *)textView
{
    if (!_textView) {
        
        
        CGRect frame = CGRectMake(50, 6, ScreenWid-142, 38);
        
        //        _textView = [[PPStickerTextView alloc] initWithFrame:self.bounds];
        _textView = [[PPStickerTextView alloc] initWithFrame:frame];
        
        _textView.delegate = self;
        
        _textView.font = [UIFont systemFontOfSize:PPStickerTextViewFontSize];
        _textView.scrollsToTop = NO;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.enablesReturnKeyAutomatically = YES;
        //   _textView.placeholder = NSLocalizedString(@"Enter message", @"Enter message");
        _textView.placeholderColor = [UIColor pp_colorWithRGBString:@"#B4B4B4"];
        _textView.textContainerInset = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            _textView.textDragInteraction.enabled = NO;
        }
    }
    
    _textView.autoresizingMask = UIViewAutoresizingNone;
    
    CGFloat height = 0.0f;
    CGSize size = CGSizeMake(_textView.textContainer.size.width, MAXFLOAT);
    CGRect rect = [@"W" boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:_textView.font}
                                     context:nil];
    height = rect.size.height;
    UIEdgeInsets inset = _textView.textContainerInset;
    inset.top = (_textView.bounds.size.height - height) / 2.0f;
    inset.bottom = inset.top;
    _textView.textContainerInset = inset;
    
    _textView.layer.borderColor = [UIColor pp_colorWithRGBString:@"#dadada"].CGColor;
    _textView.layer.borderWidth =0.5;
    _textView.layer.cornerRadius =5.0;
    return _textView;
}

- (UIView *)separatedLine
{
    if (!_separatedLine) {
        _separatedLine = [[UIView alloc]init];
        _separatedLine.backgroundColor = [UIColor pp_colorWithRGBString:@"#dadada"];
    }
    return _separatedLine;
}


-(PPButton*)voicebutton{
    
    if (!_voicebutton) {
        _voicebutton = [[PPButton alloc] init];
        [_voicebutton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_voicebutton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        
        _voicebutton.touchInsets = UIEdgeInsetsMake(-12, -20, -12, -20);
        
        [_voicebutton addTarget:self action:@selector(voicebuttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return _voicebutton;
}

-(PPButton*)addbutton{
    
    
    if (!_addbutton) {
        _addbutton = [[PPButton alloc] init];
        [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        
        _addbutton.touchInsets = UIEdgeInsetsMake(-12, -20, -12, -20);
        [_addbutton addTarget:self action:@selector(addbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return _addbutton;
    
}



- (PPButton *)emojiToggleButton
{
    if (!_emojiToggleButton) {
        _emojiToggleButton = [[PPButton alloc] init];
        [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        
        _emojiToggleButton.touchInsets = UIEdgeInsetsMake(-12, -20, -12, -20);
        
        [_emojiToggleButton addTarget:self action:@selector(toggleKeyboardDidClick2:) forControlEvents:UIControlEventTouchUpInside];
        
        //  [_emojiToggleButton addTarget:self action:@selector(toggleKeyboardDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiToggleButton;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;UIColor* bkColorLight;
    UIColor* textColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
        bkColorLight = [UIColor colorNamed:@"inputViewBkColor"];
        textColor = [UIColor colorNamed:@"textColor"];
    }
    else{
        textColor= [UIColor colorWithHexString:@"#f4f3f3"];
        bkColor = [UIColor colorWithHexString:@"#f4f3f3"];
        bkColorLight= [UIColor colorWithHexString:@"#e4e3e3"];
    }
    if(_textView!=nil){
        _textView.backgroundColor = bkColorLight;
        _textView.textColor = textColor;
    }
    [self setTalkButtonColor:false];
    if(_bottomBGView!=nil){
        _bottomBGView.backgroundColor = bkColorLight;
    }
    if(_chatBoxMoreView!=nil){
        _chatBoxMoreView.backgroundColor = bkColorLight;
    }
    self.backgroundColor = bkColorLight;
}

-(void)setTalkButtonColor:(BOOL)light{
    UIColor* frontColor;
    if (@available(iOS 11.0, *)) {
        frontColor = [UIColor colorNamed:@"mainBKColorLight"];
    }
    else{
        frontColor = [UIColor colorWithHexString:@"#f4f3f3"];
    }
    const CGFloat *components = CGColorGetComponents(frontColor.CGColor);
    if(light){
        frontColor = [UIColor colorWithRed:components[0]+0.15 green:components[0]+0.15 blue:components[0]+0.15 alpha:1];
    }else{
        //frontColor = [UIColor colorWithRed: green: blue: alpha:1]
    }
    
    if(_talkbutton!=nil){
        [_talkbutton setBackgroundColor:frontColor];
    }
}

-(UIButton*)talkbutton{
    
    if (!_talkbutton) {
        _talkbutton = [[UIButton alloc] init];
        //        [_talkbutton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        //        [_talkbutton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        
        //    _addbutton.touchInsets = UIEdgeInsetsMake(-12, -20, -12, -20);
        
        
        
        [_talkbutton setTitle:NSLocalizedString(@"Hold to Talk", @"Hold to Talk") forState:UIControlStateNormal];
        [_talkbutton setTitle:NSLocalizedString(@"Release to send", @"Release to send") forState:UIControlStateDisabled];
        
        
        [_talkbutton setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
        
        
        
        [_talkbutton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_talkbutton.layer setMasksToBounds:YES];
        [_talkbutton.layer setCornerRadius:4.0f];
        [_talkbutton.layer setBorderWidth:0.5f];
        [_talkbutton.layer setBorderColor: [UIColor pp_colorWithRGBString:@"#dadada"].CGColor];
        [_talkbutton setHidden:YES];
        
        //    [_talkbutton addTarget:self action:@selector(addbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(audioRecord:)];
        //        longPress.minimumPressDuration = 0.2;
        //        [_talkbutton addGestureRecognizer:longPress];
        
        //        [_talkbutton addTarget:self action:@selector(talkButtonDown:) forControlEvents:UIControlEventTouchDown];
        //        [_talkbutton addTarget:self action:@selector(talkButtonUpInside:) forControlEvents:UIControlEventTouchUpInside];
        //        [_talkbutton addTarget:self action:@selector(talkButtonUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        //        [_talkbutton addTarget:self action:@selector(talkButtonUpOutside:) forControlEvents:UIControlEventTouchCancel];
        
        
        
        UILongPressGestureRecognizer * longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGesture:)];
        [_talkbutton addGestureRecognizer:longGesture];
        
        longGesture.minimumPressDuration = 0.3;//设置响应时间
        
        
        
    }
    return _talkbutton;
    
    
}


-(recordingView*)recordingview
{
    
    if (!_recordingview) {
        
        _recordingview = [[recordingView alloc]initWithFrame:CGRectMake((ScreenWid-160)/2, (ScreenHeight-160)/2, 150, 150)];
    }
    
    return _recordingview;
    
    
}


- (PPStickerKeyboard *)stickerKeyboard
{
    if (!_stickerKeyboard) {
        _stickerKeyboard = [[PPStickerKeyboard alloc] init];
        _stickerKeyboard.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), [self.stickerKeyboard heightThatFits]);
        _stickerKeyboard.delegate = self;
    }
    return _stickerKeyboard;
}

- (UIView *)bottomBGView
{
    if (!_bottomBGView) {
        _bottomBGView = [[UIView alloc] init];
    }
    return _bottomBGView;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.bottomBGView.frame = CGRectMake(0, CGRectGetMaxY(frame), CGRectGetWidth(self.bounds), UIScreen.mainScreen.bounds.size.height - CGRectGetMaxY(frame));
}

- (void)setFrame:(CGRect)frame animated:(BOOL)animated
{
    if (CGRectEqualToRect(frame, self.frame)) {
        return;
    }
    
    void (^ changesAnimations)(void) = ^{
        [self setFrame:frame];
        [self setNeedsLayout];
    };
    
    if (changesAnimations) {
        if (animated) {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:changesAnimations completion:nil];
        } else {
            changesAnimations();
        }
    }
}

- (void)setKeepsPreModeTextViewWillEdited:(BOOL)keepsPreModeTextViewWillEdited
{
    _keepsPreModeTextViewWillEdited = keepsPreModeTextViewWillEdited;
    if (!keepsPreModeTextViewWillEdited) {
        self.separatedLine.hidden = NO;
        self.separatedLine.frame = [self frameSeparatedLine];
    } else {
        self.separatedLine.hidden = YES;
        self.separatedLine.frame = CGRectZero;
    }
}

#pragma mark - private method

- (void)refreshTextUI
{
    if (!self.textView.text.length) {
        return;
    }
    
    UITextRange *markedTextRange = [self.textView markedTextRange];
    UITextPosition *position = [self.textView positionFromPosition:markedTextRange.start offset:0];
    if (position) {
        return;     // 正处于输入拼音还未点确定的中间状态
    }
    
    NSRange selectedRange = self.textView.selectedRange;
    UIColor* textColor;
    if (@available(iOS 11.0, *)) {
        textColor = [UIColor colorNamed:@"textColor"];
    }
    else{
//        [UIColor pp_colorWithRGBString:@"#3B3B3B"]
        textColor= [UIColor colorWithHexString:@"#3B3B3B"];
    }
    
//    NSMutableAttributedString *attributedComment = [[NSMutableAttributedString alloc] initWithString:self.plainText attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:PPStickerTextViewFontSize], NSForegroundColorAttributeName: textColor}];
    NSMutableAttributedString *attributedComment = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    // 匹配表情
    [PPStickerDataManager.sharedInstance replaceEmojiForAttributedString:attributedComment font:[UIFont systemFontOfSize:PPStickerTextViewFontSize]];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = PPStickerTextViewLineSpacing;
    [attributedComment addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:attributedComment.pp_rangeOfAll];
    [attributedComment addAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:PPStickerTextViewFontSize], NSForegroundColorAttributeName: textColor} range:NSMakeRange(0,attributedComment.length)];
    
    NSUInteger offset = self.textView.attributedText.length - attributedComment.length;
    self.textView.attributedText = attributedComment;
    self.textView.selectedRange = NSMakeRange(selectedRange.location - offset, 0);
    
    
    // self.textView.backgroundColor = [UIColor orangeColor];
    
}

- (void)toggleKeyboardDidClick:(id)sender
{
    [self changeKeyboardTo:(self.keyboardType == PPKeyboardTypeSystem ? PPKeyboardTypeSticker : PPKeyboardTypeSystem)];
}

- (void)toggleKeyboardDidClick2:(id)sender
{
    //  [self changeKeyboardTo:(self.keyboardType == PPKeyboardTypeSystem ? PPKeyboardTypeSticker : PPKeyboardTypeSystem)];
    
    [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
    [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
    
    ZXChatBoxStatus lastStatus = self.status;// 记录下上次的状态
    if (lastStatus == TLChatBoxStatusShowFace) {
        // 正在显示表情，改为现实键盘状态
        self.status = TLChatBoxStatusShowKeyboard;
        
        [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        [self.textView becomeFirstResponder];
        //        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
        //            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        //        }
        
        
        self.textView.inputView = nil;                          // 切换到系统键盘
        [self.textView reloadInputViews];                       // 调用reloadInputViews方法会立刻进行键盘的切换
        
        [self.textView becomeFirstResponder];
        
    }
    else {
        
        self.status = TLChatBoxStatusShowFace;
        [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
        
        
        
        if (lastStatus == TLChatBoxStatusShowMore) {
            //            [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
            //            [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
            
            self.textView.inputView = self.stickerKeyboard;         // 切换到自定义的表情键盘
            [self.textView reloadInputViews];
            [self.textView becomeFirstResponder];
            
        }
        else if (lastStatus == TLChatBoxStatusShowVoice) {
            [_voicebutton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
            [_voicebutton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
            [_talkbutton setHidden:YES];
            [_textView setHidden:NO];
            [self textViewDidChange:self.textView];
            
            
            self.textView.inputView = self.stickerKeyboard;         // 切换到自定义的表情键盘
            [self.textView reloadInputViews];
            [self.textView becomeFirstResponder];
            
            
        }
        else if (lastStatus == TLChatBoxStatusShowKeyboard) {
            
            //   [self.textView resignFirstResponder];
            
            
            self.textView.inputView = self.stickerKeyboard;         // 切换到自定义的表情键盘
            [self.textView reloadInputViews];
            [self.textView becomeFirstResponder];
            
            
        }
        else
        {
            self.textView.inputView = self.stickerKeyboard;         // 切换到自定义的表情键盘
            [self.textView reloadInputViews];
            [self.textView becomeFirstResponder];
            
        }
        
        //        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
        //
        //            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        //
        //        }
    }
    
}


-(void)voicebuttonClick:(id)sender{
    
    NSLog(@"voicebuttonClick");
    
    ZXChatBoxStatus lastStatus = self.status;
    if (lastStatus == TLChatBoxStatusShowVoice) {      // 正在显示talkButton，改为现实键盘状态
        self.status = TLChatBoxStatusShowKeyboard;
        [self.talkbutton setHidden:YES];
        [self.textView setHidden:NO];
        [self.textView becomeFirstResponder];
        [_voicebutton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_voicebutton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        
        [self textViewDidChange:self.textView];
        //        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
        //            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        //        }
        
        
        
        
    }
    else {
        // 显示talkButton
        //        self.curHeight = HEIGHT_TABBAR;
        //        [self setFrameHeight:self.curHeight];
        self.status = TLChatBoxStatusShowVoice;// 如果不是显示讲话的Button，就显示讲话的Button，状态也改变为 shouvoice
        [self.textView resignFirstResponder];
        [self.textView setHidden:YES];
        [self.talkbutton setHidden:NO];
        [_voicebutton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        [_voicebutton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
        if (lastStatus == TLChatBoxStatusShowFace) {
            [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
            [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        }
        else if (lastStatus == TLChatBoxStatusShowMore) {
            [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
            [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        }
        //        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
        //
        //            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        //
        //        }
        self.textView.inputView = nil;
        //     [self.textView reloadInputViews];
        [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        
        
    }
    //  }
    
    
}

-(void)addbuttonClick:(id)sender{
    
    NSLog(@"addbuttonClick");
    ZXChatBoxStatus lastStatus = self.status;
    
    
    
    
    if (lastStatus == TLChatBoxStatusShowMore) {
        
        self.textView.inputView = nil;         // 切换到键盘
        [self.textView reloadInputViews];
        
        self.status = TLChatBoxStatusShowKeyboard;
        
        [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        
        
        return;
    }
    else
    {
        
        self.status = TLChatBoxStatusShowMore;
        
        self.textView.inputView = self.chatBoxMoreView;         // 切换到更多
        [self.textView reloadInputViews];
        //    [self.textView becomeFirstResponder];
        
        
        [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        
        
        
        [self.talkbutton setHidden:YES];
        [self.textView setHidden:NO];
        [self.textView becomeFirstResponder];
        [_voicebutton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_voicebutton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        
        [_addbutton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        [_addbutton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"]forState:UIControlStateHighlighted];
        
        
    }
    
}

- (CGFloat)heightWithLine:(NSInteger)lineNumber
{
    NSString *onelineStr = [[NSString alloc] init];
    CGRect onelineRect = [onelineStr boundingRectWithSize:CGSizeMake(self.textView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:PPStickerTextViewFontSize] } context:nil];
    CGFloat heigth = lineNumber * onelineRect.size.height + (lineNumber - 1) * PPStickerTextViewLineSpacing;
    return heigth;
}

- (CGRect)frameTextView
{
    
    return CGRectMake(50, 6, ScreenWid-142, 38);
    
    CGFloat minX = (self.textView.isFirstResponder ? PPStickerTextViewTextViewLeftRightPadding : PPStickerTextViewTextViewUnfocusLeftRightPadding);
    CGFloat width = self.bounds.size.width - (2 * minX);
    
    CGFloat height = 0;
    if (self.keepsPreModeTextViewWillEdited) {
        height = CGRectGetHeight(self.bounds) - 2 * PPStickerTextViewTextViewTopMargin;
    } else {
        height = CGRectGetHeight(self.bounds) - PPStickerTextViewTextViewTopMargin - PPStickerTextViewTextViewBottomMargin - PPStickerTextViewEmojiToggleLength;
    }
    if (height < 0) {
        height = self.bounds.size.height;
    }
    
    //    return CGRectMake(minX, PPStickerTextViewTextViewTopMargin, width, height);
    
    NSLog(@"frameTextView");
    
    return CGRectMake(minX+40, PPStickerTextViewTextViewTopMargin, width, height);
}

- (CGRect)frameSeparatedLine
{
    return CGRectMake(0, 0, self.bounds.size.width, PPOnePixelToPoint());
    
    //    return CGRectMake(0, CGRectGetHeight(self.bounds) - PPStickerTextViewEmojiToggleLength, self.bounds.size.width, PPOnePixelToPoint());
}

- (CGRect)frameEmojiToggleButton
{
    //    return CGRectMake(PPStickerTextViewTextViewLeftRightPadding, CGRectGetHeight(self.bounds) - (PPStickerTextViewEmojiToggleLength + PPStickerTextViewToggleButtonLength) / 2, PPStickerTextViewToggleButtonLength, PPStickerTextViewToggleButtonLength);
    
    return CGRectMake(ScreenWid-84, 8, 34, 34);
    
}

- (CGRect)frameVoiceButton
{
    
    return CGRectMake(8, 8, 34, 34);
    
}

- (CGRect)frameAddButton
{
    
    return CGRectMake(ScreenWid-42, 8, 34, 34);
    
}

- (CGRect)frameTalkButton;
{
    
    return CGRectMake(50, 6, ScreenWid-142, 38);
    
}




#pragma mark - UITextView

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.keepsPreModeTextViewWillEdited = NO;
    //  [self.inputView changeKeyboardTo:PPKeyboardTypeSystem];
    
    
    //    if ( self.textView.inputView ==  _chatBoxMoreView ){
    //
    //        self.textView.inputView = nil;                          // 切换到系统键盘
    //        [self.textView reloadInputViews];
    //        self.status = TLChatBoxStatusShowKeyboard;
    //
    //    }
    
    
    if ([self.delegate respondsToSelector:@selector(stickerInputViewShouldBeginEditing:)]) {
        return [self.delegate stickerInputViewShouldBeginEditing:self];
    } else {
        return YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([@"\n" isEqualToString:text]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(stickerInputViewDidClickSendButton:)]) {
            [self.delegate stickerInputViewDidClickSendButton:self];
        }
        return NO;
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.keepsPreModeTextViewWillEdited = YES;
    CGRect inputViewFrame = self.frame;
    CGFloat textViewHeight = [self heightThatFits];
    inputViewFrame.origin.y = CGRectGetHeight(self.superview.bounds) - textViewHeight - PP_SAFEAREAINSETS(self.superview).bottom;
    inputViewFrame.size.height = textViewHeight;
    self.frame = inputViewFrame;
    
    if ([self.delegate respondsToSelector:@selector(stickerInputViewDidEndEditing:)]) {
        [self.delegate stickerInputViewDidEndEditing:self];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshTextUI];
    
    CGSize size = [self sizeThatFits:self.bounds.size];
    CGRect newFrame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame) - size.height, size.width, size.height);
    
    [self setFrame:newFrame animated:YES];
    
    if (!self.keepsPreModeTextViewWillEdited) {
        self.textView.frame = [self frameTextView];
    }
    [self.textView scrollRangeToVisible:self.textView.selectedRange];
    
    
    if ([self.delegate respondsToSelector:@selector(stickerInputViewDidChange:)]) {
        [self.delegate stickerInputViewDidChange:self];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self.textView isFirstResponder]) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (!CGRectContainsPoint(self.bounds, touchPoint)) {
        if ([self isFirstResponder]) {
            [self resignFirstResponder];
        }
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (BOOL)isFirstResponder
{
    return [self.textView isFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    self.keepsPreModeTextViewWillEdited = YES;
    //    [self changeKeyboardTo:PPKeyboardTypeNone];
    [self setNeedsLayout];
    return [self.textView resignFirstResponder];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (!self.superview) {
        return;
    }
    
    if (!self.bottomBGView.superview) {
        [self.superview insertSubview:self.bottomBGView belowSubview:self];
    }
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect inputViewFrame = self.frame;
    CGFloat textViewHeight = [self heightThatFits];
    inputViewFrame.origin.y = CGRectGetHeight(self.superview.bounds) - CGRectGetHeight(keyboardFrame) - textViewHeight;
    inputViewFrame.size.height = textViewHeight;
    
    [UIView animateWithDuration:duration animations:^{
        self.frame = inputViewFrame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (!self.superview) {
        return;
    }
    
    if (self.bottomBGView.superview) {
        [self.bottomBGView removeFromSuperview];
    }
    
    
    
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect inputViewFrame = self.frame;
    CGFloat textViewHeight = [self heightThatFits];
    inputViewFrame.origin.y = CGRectGetHeight(self.superview.bounds) - textViewHeight - PP_SAFEAREAINSETS(self.superview).bottom;
    inputViewFrame.size.height = textViewHeight;
    
    [UIView animateWithDuration:duration animations:^{
        self.frame = inputViewFrame;
    }];
    
    self.keyboardType = (self.keyboardType == PPKeyboardTypeSystem ? PPKeyboardTypeSticker : PPKeyboardTypeSystem);
}

#pragma mark - PPStickerKeyboardDelegate

- (void)stickerKeyboard:(PPStickerKeyboard *)stickerKeyboard didClickEmoji:(PPEmoji *)emoji
{
    if (!emoji) {
        return;
    }
    
    UIImage *emojiImage = [UIImage imageNamed:[@"Sticker.bundle" stringByAppendingPathComponent:emoji.imageName]];
    if (!emojiImage) {
        return;
    }
    
    NSRange selectedRange = self.textView.selectedRange;
    
    NSString *emojiString;
//    if(emoji.utf32Type)//unicode
//    {
//        emojiString = emoji.emojiDescription;
//    }else{
        emojiString = [NSString stringWithFormat:@"[:%@]", emoji.emojiDescription];
//    }
    
    NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc] initWithString:emojiString];
    [emojiAttributedString pp_setTextBackedString:[PPTextBackedString stringWithString:emojiString] range:emojiAttributedString.pp_rangeOfAll];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [attributedText replaceCharactersInRange:selectedRange withAttributedString:emojiAttributedString];
    self.textView.attributedText = attributedText;
    self.textView.selectedRange = NSMakeRange(selectedRange.location + emojiAttributedString.length, 0);
    
    [self textViewDidChange:self.textView];
}

- (void)stickerKeyboardDidClickDeleteButton:(PPStickerKeyboard *)stickerKeyboard
{
    NSRange selectedRange = self.textView.selectedRange;
    if (selectedRange.location == 0 && selectedRange.length == 0) {
        return;
    }
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    
    if (selectedRange.length > 0) {
        [attributedText deleteCharactersInRange:selectedRange];
        self.textView.attributedText = attributedText;
        self.textView.selectedRange = NSMakeRange(selectedRange.location, 0);
    } else {
        int len =1;
//        if(selectedRange.location>=2){
//            PPTextBackedString *textBackedString = [self.textView.attributedText pp_backedTextForRange:NSMakeRange(selectedRange.location-2, 2)];
//            if(textBackedString!=nil&&![NSNull isEqual:textBackedString]){
//                len = (int)textBackedString.string.length;
//            }
//        }
        
        [attributedText deleteCharactersInRange:NSMakeRange(selectedRange.location - len, len)];
        self.textView.attributedText = attributedText;
        self.textView.selectedRange = NSMakeRange(selectedRange.location - len, 0);
        
//        NSRange range = NSMakeRange(selectedRange.location - 1, 1);
//
//        [self enumerateAttribute:NSTextAttachment inRange:range options:kNilOptions usingBlock:^(id value, NSRange range, BOOL *stop) {
//            if(value as)
//            if (backed && backed.string) {
//                [result appendString:backed.string];
//            } else {
//                [result appendString:[string substringWithRange:range]];
//            }
//        }];
//
//        NSString *string = [self.textView.attributedText pp_plainTextForRange:range];
//        int deletLen = 1;
//        if (string.length) {
//            deletLen = (int)string.length;
//        }
//
//        [attributedText deleteCharactersInRange:NSMakeRange(selectedRange.location - deletLen, deletLen)];
//        self.textView.attributedText = attributedText;
//        self.textView.selectedRange = NSMakeRange(selectedRange.location - deletLen, 0);
    }
    
    [self textViewDidChange:self.textView];
}

- (void)stickerKeyboardDidClickSendButton:(PPStickerKeyboard *)stickerKeyboard
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerInputViewDidClickSendButton:)]) {
        [self.delegate stickerInputViewDidClickSendButton:self];
        
        [self.textView hidePlaceholder];
        
    }
}

-(void)showtextview{
    
    [self.textView becomeFirstResponder];
    
    
}

-(void)setEnableFileMessage:(bool)enable{
    self.fileMessage = enable;
}
-(void)setface{
    
    
    
    if (self.status == TLChatBoxStatusShowVoice) {
        
        
    }
    else if (self.status == TLChatBoxStatusShowMore){
        
        self.textView.inputView = nil;                          // 切换到系统键盘
        //   [self.textView reloadInputViews];
        self.status = TLChatBoxStatusShowKeyboard;
        
    }
    
    else
    {
        
        
        [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_emojiToggleButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        
        self.status = TLChatBoxStatusShowKeyboard;
        
    }
    
    [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
    [_addbutton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
    
}


- (void)chatBoxChangeStatusForm:(ZXChatBoxStatus)fromStatus to:(ZXChatBoxStatus)toStatus{
    
    
    
    
}

// 添加创建更多View
- (chatMoreView *)chatBoxMoreView
{
    if (_chatBoxMoreView == nil) {
        
        CGFloat spacing1 = 30;
        CGFloat spacing2 = 25;
        
        CGFloat width = (ScreenWid-spacing1*2 - spacing2*3)/4;
        _chatBoxMoreView = [[chatMoreView alloc]initWithFrame:CGRectMake(0, 0, ScreenWid, width*2+spacing2*3+20+7)];
        
        [_chatBoxMoreView setDelegate:self];
        [_chatBoxMoreView setUI];
    }
    return _chatBoxMoreView;
}

#pragma mark-
#pragma mark moreviewdelete

- (void)sendImage{
    
    if (self.delegate) {
        [self.delegate ChatSendImage];
    }
}

- (void)sendFile{
    
    if (self.delegate) {
        [self.delegate ChatSendFile];
    }
}

- (void)sendCustomCamera{
    
    
    if (self.delegate) {
        [self.delegate ChatSendCustomCamera];
    }
}


-(void)makeCall:(BOOL)video{
    if (self.delegate) {
        [self.delegate ChatMakeCall:video];
    }
}


-(void)beginRecord{
    if (self.delegate) {
        [self.delegate beginRecord];
    }
}

-(void)finshRecord{
    if (self.delegate) {
        [self.delegate finshRecord];
    }
}

-(void)cancelRecord{
    if (self.delegate) {
        [self.delegate cancelRecord];
    }
}


#pragma mark-
#pragma mark addtalkbuttondelete

- (void)talkButtonDown:(UIButton *)sender
{
    [_talkbutton setTitle:NSLocalizedString(@"Release to send", @"Release to send")forState:UIControlStateNormal];
    [self setTalkButtonColor:TRUE];
    NSLog(@"talkButtonDown ");
}

- (void)talkButtonUpInside:(UIButton *)sender
{
    [_talkbutton setTitle:NSLocalizedString(@"Hold to Talk", @"Hold to Talk") forState:UIControlStateNormal];
    NSLog(@"talkButtonUpInside");
    [self setTalkButtonColor:false];
}

- (void)talkButtonUpOutside:(UIButton *)sender
{
    [_talkbutton setTitle:NSLocalizedString(@"Hold to Talk", @"Hold to Talk") forState:UIControlStateNormal];
    [self setTalkButtonColor:false];
    NSLog(@"talkButtonUpOutside");
    
}
bool inRecord = false;
-(void)longGesture:(UILongPressGestureRecognizer *)gesture
{
    
    int sendState = 0;
    CGPoint point = [gesture locationInView:_talkbutton];
    if (point.y<0) {
        sendState = 1;
        [self setTalkButtonColor:false];
        [self.recordingview setUI:1];

    } else {
        [self setTalkButtonColor:TRUE];
        sendState = 0;
        [self.recordingview setUI:0];
        
    } //手势状态
    switch (gesture.state)
    {
            
        case UIGestureRecognizerStateBegan: {
            
            if(self.delegate!=NULL&&[self.delegate canBeginRecord]){
                inRecord = true;
                [_talkbutton setTitle:NSLocalizedString(@"Release to send", @"Release to send") forState:UIControlStateNormal];
                
                UIApplication *ap = [UIApplication sharedApplication];
                [self setTalkButtonColor:TRUE];
                [ap.keyWindow addSubview:self.recordingview];
                [self.recordingview setUI:0];
                [self beginRecord];
            }else{
            }
            
        }
            
            break;
        case UIGestureRecognizerStateEnded: {
            if(inRecord){
                if (sendState == 0) {
                    [self finshRecord];
                } else {
                    [self cancelRecord];
                }
            }
            
            [_talkbutton setTitle:NSLocalizedString(@"Hold to Talk", @"Hold to Talk")forState:UIControlStateNormal];
            [self setTalkButtonColor:false];
            [self stoprecordingview];
            
        } break;
        case UIGestureRecognizerStateFailed:
            break;
        default:
            break;
            
    }
    
    
    
    
}


-(void)stoprecordingview{
    
    inRecord = FALSE;
    [self.recordingview removeFromSuperview];
}


-(void)audioRecord:(id)sender{
    
    
    
}

@end
