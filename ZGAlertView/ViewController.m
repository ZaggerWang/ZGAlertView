//
//  ViewController.m
//  ZGAlertView
//
//  Created by zagger on 15/7/8.
//  Copyright (c) 2015年 zaggerwang@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "ZGAlertView.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, ZGAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.view addSubview:self.tableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}


#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count + 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    if (indexPath.row - 3 >= 0) {
        cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row - 3];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZGAlertView *alertView = nil;
    switch (indexPath.row - 3) {
        case 0:{
            alertView = [[ZGAlertView alloc] initWithTitle:@"我就是标题" message:@"我是内容我是内容我是内容我是内容我是内容我是内容我是内容" cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        }
            break;
        case 1:{
            alertView = [[ZGAlertView alloc] initWithTitle:@"我就是标题" message:@"我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容" cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        }
            break;
        case 2:{
            alertView = [[ZGAlertView alloc] initWithTitle:@"我就是标题" message:@"我是内我是内容我是内容我是内容我是内容我是内容我是内容容我是内容我是内容我是内容" cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.rowMaxButtonNumber = 1;
        }
            break;
        case 3:{
            alertView = [[ZGAlertView alloc] initWithTitle:@"我就是标题" message:@"我是内我是内容我是内容我是内容我是内容我是内容我是内容我是内容容我是内容我是内容我是内容" cancelButtonTitle:@"取消" otherButtonTitles:@"下次再说",@"确定", nil];
            alertView.rowMaxButtonNumber = 3;
        }
            break;
        case 4:{
            alertView = [[ZGAlertView alloc] initWithTitle:@"我就是标题" message:@"我是内容我我是内容我是内容我是内容是内容我是内容我是内容" cancelButtonTitle:@"取消" otherButtonTitles:@"确定",@"不确定",@"确不确定",@"到底确不确定", nil];
        }
            break;
        case 5:{
            alertView = [[ZGAlertView alloc] initWithTitle:@"我就是标题" message:@"我是我是内容我是内容我是内容内容我是内容我是内容我是内容" cancelButtonTitle:@"取消" otherButtonTitles:@"确定",@"不确定",@"确不确定",@"到底确不确定", nil];
            alertView.cancelButtonIndex = 3;
        }
            break;
        case 6:{
            alertView = [[ZGAlertView alloc] initWithTitle:@"我就是标题" message:@"我是内容我我是内容我是内容我是内容我是内容我是内容我是内容我是内容我是内容是内容我是内容我是内容" cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            
            UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
            customButton.backgroundColor = [UIColor orangeColor];
            [customButton setTitle:@"我是一个自定义按钮" forState:UIControlStateNormal];
            
            [alertView addCustomButton:customButton toIndex:1];
        }
            break;
            
        default:
            break;
    }
    
    if (alertView) {
        alertView.dismissBlock = ^(NSInteger buttonIndex) {
            NSLog(@"block response click at index %ld",(long)buttonIndex);
        };
        
        [alertView show];
    }
}

#pragma mark - ZGAlertViewDelegate
- (void)alertView:(ZGAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"delegate response click at index %ld",(long)buttonIndex);
}


#pragma mark - 
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"单个按钮",@"两个按钮同行",@"两个按钮不同行",@"多个按钮同行",@"每行一个按钮",@"指定取消按钮位置",@"添加自定义按钮"];
    }
    return _dataArray;
}

@end
