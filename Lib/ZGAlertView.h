//
//  ZGAlertView.h
//  ZGAlertView
//
//  Created by zagger on 15/7/8.
//  Copyright © 2015年 zaggerwang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZGAlertViewDelegate;
@interface ZGAlertView : UIView

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, strong) UIFont  *titleFont;
@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, readonly, copy) NSString *message;
@property (nonatomic, strong) UIFont  *messageFont;
@property (nonatomic, strong) UIColor *messageColor;

/** 遮罩颜色 */
@property (nonatomic, strong) UIColor *maskColor;

/** 取消按钮的index，默认为0，可以通过设置该值来改变取消按钮的位置 */
@property (nonatomic, assign) NSInteger cancelButtonIndex;

/** 同一行中，最多能摆放的按钮数，默认为2，当button总数超过该值时，会将button分行显示、且每行只显示一个 */
@property (nonatomic, assign) NSInteger rowMaxButtonNumber;

//通过delegate或block来实现按钮点击事件的回调
@property (nonatomic, weak) id<ZGAlertViewDelegate> delegate;
@property (nonatomic, copy) void(^dismissBlock)(NSInteger clickIndex);

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;

- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

/**
 *  添加一个自定义的button到指定的位置
 *
 *  @param button      自定义的按钮
 *  @param buttonIndex 插入的位置，越界时会自动做处理成最大值或最小值
 */
- (void)addCustomButton:(UIButton *)button toIndex:(NSInteger)buttonIndex;

@end


@protocol ZGAlertViewDelegate <NSObject>

@required
- (void)alertView:(ZGAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface UIImage (Expand)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end