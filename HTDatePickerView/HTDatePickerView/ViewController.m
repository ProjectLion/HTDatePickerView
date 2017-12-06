//
//  ViewController.m
//  HTDatePickerView
//
//  Created by apple on 2017/12/6.
//  Copyright © 2017年 HT. All rights reserved.
//

#import "ViewController.h"
#import "HTDatePickerView.h"

@interface ViewController ()
{
    HTDatePickerView *dataPicker;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 200, 50);
    [btn setTitle:@"推出时间选择器" forState:0];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor redColor] forState:0];
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 200, 200, 50)];
    timeLabel.textColor = [UIColor redColor];
    timeLabel.textAlignment = 1;
    timeLabel.text = @"时间";
    [self.view addSubview:timeLabel];
    
    dataPicker = [HTDatePickerView htDatePickerViewWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 260) style:HTDatePickerStyle_YMDhms];
    dataPicker.cancelBlock = ^{
        NSLog(@"取消");
    };
    dataPicker.ensureBlock = ^(NSString *date) {
        NSLog(@"时间是：%@", date);
        timeLabel.text = date;
    };
    dataPicker.isCanSelectCurrentTimeBefore = YES;
    dataPicker.buttonBorderColor = [UIColor redColor];
    dataPicker.cancelBtnColor = [UIColor redColor];
    [self.view addSubview:dataPicker];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)clickBtn{
    [dataPicker showDatePicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
