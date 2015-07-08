//
//  ZGAlertView.m
//  ZGAlertView
//
//  Created by zagger on 15/7/8.
//  Copyright © 2015年 zaggerwang@gmail.com. All rights reserved.
//

#import "ZGAlertView.h"
#import "UIView+Position.h"

#define CURRENT_WINDOW [UIApplication sharedApplication].keyWindow

CGFloat const kTopMargin = 20.0;//contentView内的上边距
CGFloat const kBottomMargin = 20.0;//contentView内的下边距
CGFloat const kHorizonMargin = 15.0;//contentView内的水平边距
CGFloat const kHorizonPadding = 10.0;//button水平方向间距
CGFloat const kVerticalPadding = 10.0;//button垂直方向间距
CGFloat const kTitleMessagePadding = 10;//title和message垂直方向间距
CGFloat const kMessageButtonsPadding = 10;//buttons与message（或title）垂直方向间距

CGFloat const kButtonHeight = 44.0;//button的高度
CGFloat const kContentHorizonMargin = 20;//contentView距离屏幕两边的距离


@interface ZGAlertView () {
    UIFont  *_titleFont;
    UIColor *_titleColor;
    UIFont  *_messageFont;
    UIColor *_messageColor;
}

@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSString *message;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) NSMutableArray *textFieldArray;

@end


@implementation ZGAlertView

#pragma mark - Life cycle
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    if (self = [super initWithFrame:CURRENT_WINDOW.bounds]) {
        
        self.rowMaxButtonNumber = 2;//同一行默认最多显示两个按钮
        self.maskColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.backgroundColor = [UIColor whiteColor];
        
        self.title = title;
        self.titleLabel.text = title;
        self.message = message;
        self.messageLabel.text = message;
        
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.messageLabel];
        
        va_list args;
        va_start(args, otherButtonTitles);
        NSMutableArray *buttonTitles = [self parserOtherButtonTitles:otherButtonTitles list:args];
        va_end(args);
        
        [self generateButtonsWithCancelButtonTitle:cancelButtonTitle otherButtonTitles:buttonTitles];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat yPos = kTopMargin;
    CGFloat maxWidth = self.width - 2*kContentHorizonMargin - 2*kHorizonMargin;
    if (self.title.length > 0) {
        self.titleLabel.width = maxWidth;
        [self.titleLabel sizeToFit];
        self.titleLabel.frame = CGRectMake(kHorizonMargin, yPos, maxWidth, self.titleLabel.height);
        yPos = self.titleLabel.bottom;
    } else {
        [self.titleLabel removeFromSuperview];
    }
    if (self.message.length > 0) {
        self.messageLabel.width = maxWidth;
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(kHorizonMargin,
                                             yPos <= kTopMargin ?: yPos + kTitleMessagePadding ,
                                             maxWidth, self.messageLabel.height);
        yPos = self.messageLabel.bottom;
    } else {
        [self.messageLabel removeFromSuperview];
    }
    
    yPos += kMessageButtonsPadding;
    if (self.buttonArray.count <= self.rowMaxButtonNumber) {//button在同一行中显示
        CGFloat xPos = kHorizonMargin;
        CGFloat buttonWidth = (maxWidth - (self.buttonArray.count - 1)*kHorizonPadding) / self.buttonArray.count;
        for (UIButton *button in self.buttonArray) {
            button.frame = CGRectMake(xPos, yPos, buttonWidth, kButtonHeight);
            xPos += (buttonWidth + kHorizonPadding);
        }
        
        yPos += kButtonHeight;
    }
    else {//button分行显示，每行显示一个
        CGFloat buttonWidth = maxWidth;
        for (UIButton *button in self.buttonArray) {
            button.frame = CGRectMake(kHorizonMargin, yPos, buttonWidth, kButtonHeight);
            yPos += (kButtonHeight + kVerticalPadding);
        }
        
        yPos -= kVerticalPadding;
    }
    
    self.contentView.frame = CGRectMake(kContentHorizonMargin, 0, self.width - 2*kContentHorizonMargin, yPos + kBottomMargin);
    self.contentView.centerY = 0.5*self.height;
}


#pragma mark - Events
- (void)buttonsClicked:(id)sender {
    NSInteger buttonIndex = [self.buttonArray indexOfObject:sender];
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark - Public Methods
- (void)show {
    [CURRENT_WINDOW addSubview:self];
    
    //TODO:添加不同的动画效果
    [self fadeIn];
}

- (void)hideWithAnimation:(BOOL)animated {
    //TODO:添加不同的动画效果
    if (animated) {
        [self fadeOut];
    }
    else {
        [self removeFromSuperview];
    }
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    if (buttonIndex != NSNotFound) {
        if (self.dismissBlock) {
            self.dismissBlock(buttonIndex);
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
            [self.delegate alertView:self clickedButtonAtIndex:buttonIndex];
        }
    }
    
    [self hideWithAnimation:animated];
}

- (void)addCustomButton:(UIButton *)button toIndex:(NSInteger)buttonIndex {
    if (button && [button isKindOfClass:[UIButton class]]) {
        [button addTarget:self action:@selector(buttonsClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        [self.buttonArray insertObject:button atIndex:[self validInsertIndex:buttonIndex]];
    }
}

- (void)addTextFieldWithPlaceholder:(NSString *)placeholder toIndex:(NSInteger)textFieldIndex {
    
}

- (void)addCustomTextField:(UITextField *)textField toIndex:(NSInteger)textFieldIndex {
    //TODO:添加textField
}



#pragma mark - Private Methods
- (NSMutableArray *)parserOtherButtonTitles:(NSString *)buttonTitle list:(va_list)args {
    
    NSMutableArray *argsArray = [[NSMutableArray alloc] init];
    
    for (NSString *otherButton = buttonTitle; otherButton != nil; otherButton = va_arg(args, NSString *)) {
        [argsArray addObject:otherButton];
    }
    
    return argsArray;
}

- (void)generateButtonsWithCancelButtonTitle:(NSString *)cancelButtonTitle
                           otherButtonTitles:(NSMutableArray *)otherButtonTitles {
    for (NSString *title in otherButtonTitles) {
        UIButton *otherButton = [self otherButtonWithTitle:title];
        [self.contentView addSubview:otherButton];
        [self.buttonArray addObject:otherButton];
    }
    
    if (cancelButtonTitle.length > 0) {
        UIButton *cancelButton = [self cancelButtonWithTitle:cancelButtonTitle];
        [self.contentView addSubview:cancelButton];
        _cancelButtonIndex = [self validInsertIndex:self.cancelButtonIndex];
        [self.buttonArray insertObject:cancelButton atIndex:self.cancelButtonIndex];
    } else {
        _cancelButtonIndex = -1;//没有取消按钮时，取消按钮的index置为-1
    }
}

//避免数组向index处做插入操作时越界
- (NSInteger)validInsertIndex:(NSInteger)index {
    NSInteger validIndex = MAX(0, index);
    validIndex = MIN(validIndex, self.buttonArray.count);
    return validIndex;
}

- (BOOL)isValidIndex:(NSInteger)index {
    return index >= 0 && index < self.buttonArray.count;
}

#pragma mark - Button Factory
- (UIButton *)cancelButtonWithTitle:(NSString *)title {
    return [self generalButtonWithTitle:title
                                   font:[UIFont systemFontOfSize:13.0]
                             titleColor:[UIColor whiteColor]
                        backgroundColor:[UIColor redColor]
                     highlightedBgColor:nil];
}

- (UIButton *)otherButtonWithTitle:(NSString *)title {
    return [self generalButtonWithTitle:title
                                   font:[UIFont systemFontOfSize:13.0]
                             titleColor:[UIColor whiteColor]
                        backgroundColor:[UIColor blueColor]
                     highlightedBgColor:nil];
}

- (UIButton *)generalButtonWithTitle:(NSString *)title
                                font:(UIFont *)font
                          titleColor:(UIColor *)titleColor
                     backgroundColor:(UIColor *)backgroundColor
                  highlightedBgColor:(UIColor *)highlightedBgColor {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.layer.cornerRadius = 3.0;
    button.layer.masksToBounds = YES;
    
    button.titleLabel.font = font;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:backgroundColor] forState:UIControlStateNormal];
    if (highlightedBgColor) {
        [button setBackgroundImage:[UIImage imageWithColor:highlightedBgColor] forState:UIControlStateHighlighted];
    }
    [button addTarget:self action:@selector(buttonsClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - Show Animations
- (void)fadeIn {
    self.alpha = 0;
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:nil];
}

#pragma mark - Hide Animations
- (void)fadeOut {
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark - Properties
- (UIFont *)titleFont {
    if (!_titleFont) {
        _titleFont = [UIFont boldSystemFontOfSize:15.0];//设置标题默认字体
    }
    return _titleFont;
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
}

- (UIColor *)titleColor {
    if (!_titleColor) {
        _titleColor = [UIColor blackColor];//设置标题默认颜色
    }
    return _titleColor;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (UIFont *)messageFont {
    if (!_messageFont) {
        _messageFont = [UIFont systemFontOfSize:14.0];//设置信息文本默认字体
    }
    return _messageFont;
}

- (void)setMessageFont:(UIFont *)messageFont {
    _messageFont = messageFont;
    self.messageLabel.font = messageFont;
}

- (UIColor *)messageColor {
    if (!_messageColor) {
        _messageColor = [UIColor grayColor];//设置信息文本默认颜色
    }
    return _messageColor;
}

- (void)setMessageColor:(UIColor *)messageColor {
    _messageColor = messageColor;
    self.messageLabel.textColor = messageColor;
}

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    [super setBackgroundColor:maskColor];
}

- (void)setCancelButtonIndex:(NSInteger)cancelButtonIndex {
    if (cancelButtonIndex != _cancelButtonIndex) {
        
        if ([self isValidIndex:_cancelButtonIndex]) {//调整取消按钮的位置
            UIButton *cancelButton = [self.buttonArray objectAtIndex:_cancelButtonIndex];
            [self.buttonArray removeObjectAtIndex:_cancelButtonIndex];
            _cancelButtonIndex = [self validInsertIndex:cancelButtonIndex];
            [self.buttonArray insertObject:cancelButton atIndex:_cancelButtonIndex];
        }
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.contentView.backgroundColor = backgroundColor;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.layer.cornerRadius = 5.0;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = self.titleFont;
        _titleLabel.textColor = self.titleColor;
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.font = self.messageFont;
        _messageLabel.textColor = self.messageColor;
        _messageLabel.numberOfLines = 5;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLabel;
}

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return _buttonArray;
}

- (NSMutableArray *)textFieldArray {
    if (!_textFieldArray) {
        _textFieldArray = [[NSMutableArray alloc] init];
    }
    return _textFieldArray;
}

@end



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIImage (Expand)

+ (UIImage *)imageWithColor:(UIColor *)color {
    if (!color) {
        return nil;
    }
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end

