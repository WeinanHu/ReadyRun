//
//  ViewController.m
//  酷跑
//
//  Created by Wayne on 16/5/10.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD+KR.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)loadSuccess:(UIView*)view{
    [MBProgressHUD showSuccess:@"登录成功" toView:view];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
