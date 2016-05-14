//
//  WHRegisterViewController.m
//  酷跑
//
//  Created by Wayne on 16/5/11.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHRegisterViewController.h"
#import "WHUserInfo.h"
#import "WHXMPPTool.h"
#import "MBProgressHUD+KR.h"
#import "AFNetworking.h"
#import "NSString+md5.h"
@interface WHRegisterViewController ()<WHRegisterDelegate>
@property (weak, nonatomic) IBOutlet UITextField *registerNameField;
@property (weak, nonatomic) IBOutlet UITextField *registerPasswordField;

@end

@implementation WHRegisterViewController
#pragma mark - web注册
/**web注册*/
-(void)webRegisterForServer{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //准备参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"]=[WHUserInfo sharedWHUserInfo].registerUserName;
    parameters[@"md5password"]=[[WHUserInfo sharedWHUserInfo].registerPassword md5StrXor];
    parameters[@"nickname"]= [WHUserInfo sharedWHUserInfo].registerUserName;
    parameters[@"gender"] = @1;
    [manager POST:WEBREGISTER_URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //准备头像数据
        UIImage *image = [UIImage imageNamed:@"微信"];
        NSData *headData = UIImagePNGRepresentation(image);
        NSString *imageName = [NSString stringWithFormat:@"%@HeadImage.png",[WHUserInfo sharedWHUserInfo].registerUserName];
        [formData appendPartWithFileData:headData name:@"pic" fileName:imageName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"注册成功");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"注册失败：%@",error.userInfo);
    }];
    
}
#pragma mark - WHRegisterDelegate
/**
 *  xmpp注册成功
 */
-(void)xmppDidRegisterSuccess{
    NSLog(@"通过注册界面，成功完成注册");
    //注册账号有两套，注册openfire成功后，立马发送注册web账号的请求
    [self webRegisterForServer];
    
    [MBProgressHUD showSuccess:@"注册成功" toView:self.parentViewController.presentingViewController.view];
    [self backAction:nil];
}
/**
 *  xmpp注册失败
 */
-(void)xmppDidRegisterFailed{
    NSLog(@"在注册界面注册失败");
    
    [MBProgressHUD showError:@"注册失败"];
}
#pragma mark - 按钮点击
/**
 *  返回button
 */
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**点击注册按钮*/
- (IBAction)clickRegisterButton:(id)sender {
    if (self.registerNameField.text.length == 0 || self.registerPasswordField.text.length == 0) {
        [MBProgressHUD showError:@"用户名密码不能为空"];
        return;
    }
    [WHUserInfo sharedWHUserInfo].registerUserName = self.registerNameField.text;
    [WHUserInfo sharedWHUserInfo].registerPassword = self.registerPasswordField.text;
    [WHXMPPTool sharedWHXMPPTool].registerDelegate = self;
    [[WHXMPPTool sharedWHXMPPTool] userRegister];
    
}
#pragma mark - 视图设置
/**
 *  设置textField的leftView
 */
-(void)setUpTextFieldLeftView{
    UIImageView *leftView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon"]];
    leftView.frame = CGRectMake(0, 0, 55, 20);
    leftView.contentMode = UIViewContentModeCenter;
    self.registerNameField.leftView = leftView;
    //必须设置以下leftViewMode的模式，不然不会显示leftView;
    self.registerNameField.leftViewMode = UITextFieldViewModeAlways;
    
    leftView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"lock"]];
    leftView.frame = CGRectMake(0, 0, 55, 20);
    leftView.contentMode = UIViewContentModeCenter;
    self.registerPasswordField.leftView = leftView;
    //必须设置以下leftViewMode的模式，不然不会显示leftView;
    self.registerPasswordField.leftViewMode = UITextFieldViewModeAlways;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTextFieldLeftView];

}

#pragma mark - 其他
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
