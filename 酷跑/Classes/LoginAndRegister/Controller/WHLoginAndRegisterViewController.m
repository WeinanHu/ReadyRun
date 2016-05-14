//
//  WHLoginAndRegisterViewController.m
//  酷跑
//
//  Created by Wayne on 16/5/10.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHLoginAndRegisterViewController.h"
#import "WHUserInfo.h"
#import "WHXMPPTool.h"
#import "MBProgressHUD+KR.h"
typedef enum {
    WHXMPPResultTypeLoginSuccess,
    WHXMPPResultTypeLoginFailed,
    WHXMPPResultTypeLoginNetError
}WHXMPPResultTool;
@interface WHLoginAndRegisterViewController ()<WHLoginDelegate>
/**密码输入框*/
@property (weak, nonatomic) IBOutlet UITextField *userPasswordField;
/**用户名输入框*/
@property (weak, nonatomic) IBOutlet UITextField *userNameField;

@end

@implementation WHLoginAndRegisterViewController
/**登录按钮被点击*/
- (IBAction)clickLoginButton:(UIButton *)sender {
    [WHUserInfo sharedWHUserInfo].userName = self.userNameField.text;
    [WHUserInfo sharedWHUserInfo].userPassword = self.userPasswordField.text;
    [WHXMPPTool sharedWHXMPPTool].loginDelegate = self;
    [[WHXMPPTool sharedWHXMPPTool] userLogin];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTextFieldLeftView];
    self.userNameField.text = [WHUserInfo sharedWHUserInfo].userName;
    self.userPasswordField.text = [WHUserInfo sharedWHUserInfo].userPassword;
    
    // Do any additional setup after loading the view.
}
/**
 *  设置textField的leftView
 */
-(void)setUpTextFieldLeftView{
    UIImageView *leftView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon"]];
    leftView.frame = CGRectMake(0, 0, 55, 20);
    leftView.contentMode = UIViewContentModeCenter;
    self.userNameField.leftView = leftView;
    //必须设置以下leftViewMode的模式，不然不会显示leftView;
    self.userNameField.leftViewMode = UITextFieldViewModeAlways;
    
    leftView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"lock"]];
    leftView.frame = CGRectMake(0, 0, 55, 20);
    leftView.contentMode = UIViewContentModeCenter;
    self.userPasswordField.leftView = leftView;
    //必须设置以下leftViewMode的模式，不然不会显示leftView;
    self.userPasswordField.leftViewMode = UITextFieldViewModeAlways;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WHLoginDelegate
-(void)xmppDidLoginSuccess{
    NSLog(@"********");
    
    [MBProgressHUD showSuccess:@"登录成功" toView:self.view];
    [self performSelector:@selector(loadSuccess) withObject:nil afterDelay:1];
   
    
}
-(void)loadSuccess{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = mainStoryBoard.instantiateInitialViewController;
    
}
-(void)xmppDidLoginFailed{
    NSLog(@"--------");
    [MBProgressHUD showSuccess:@"登录失败" toView:self.view];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
