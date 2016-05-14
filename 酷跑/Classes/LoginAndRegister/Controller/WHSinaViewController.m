//
//  WHSinaViewController.m
//  酷跑
//
//  Created by Wayne on 16/5/11.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHSinaViewController.h"
#import "AFNetworking.h"
#import "WHUserInfo.h"
#import "WHXMPPTool.h"
#import "MBProgressHUD+KR.h"
#import "NSString+md5.h"

#define  APPKEY       @"2075708624"
#define  REDIRECT_URI @"http://www.tedu.cn"
#define  APPSECRET    @"36a3d3dec55af644cd94a316fdd8bfd8"
@interface WHSinaViewController ()<UIWebViewDelegate,WHRegisterDelegate,WHLoginDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WHSinaViewController
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *str = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&redirect_uri=%@",APPKEY,REDIRECT_URI];
    NSURL *url = [NSURL URLWithString:str];
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    // Do any additional setup after loading the view.
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"%@",request.URL.absoluteString);
    NSString *str = request.URL.absoluteString;
    NSString *code;
    if ([str containsString:@"/?code="]) {
        NSRange range = [str rangeOfString:@"/?code="];
        code = [str substringFromIndex:(range.location+range.length)];
        NSLog(@"%@",code);
        [self accessTokenWithCode:code];
        return NO;
    }
    return YES;
}
-(void)accessTokenWithCode:(NSString*)code{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"client_id"]=APPKEY;
    parameter[@"client_secret"]=APPSECRET;
    parameter[@"grant_type"]=@"authorization_code";
    parameter[@"code"]=code;
    parameter[@"redirect_uri"]=REDIRECT_URI;
    NSString *url = @"https://api.weibo.com/oauth2/access_token";
    [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        //使用uid作为用户名，access_token作为密码，完成在xmpp服务器上的注册
        [WHUserInfo sharedWHUserInfo].registerUserName = responseObject[@"uid"];
        [WHUserInfo sharedWHUserInfo].registerPassword = responseObject[@"access_token"];
        [WHXMPPTool sharedWHXMPPTool].registerDelegate = self;
        [[WHXMPPTool sharedWHXMPPTool]userRegister];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.userInfo);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        //自动登录
        [self sinaLogin];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"注册失败：%@",error.userInfo);
    }];
    
}
-(void)sinaLogin{
    [WHUserInfo sharedWHUserInfo].userName = [WHUserInfo sharedWHUserInfo].registerUserName;
    [WHUserInfo sharedWHUserInfo].userPassword = [WHUserInfo sharedWHUserInfo].registerPassword;
    [WHXMPPTool sharedWHXMPPTool].loginDelegate = self;
    [[WHXMPPTool sharedWHXMPPTool]userLogin];
}
#pragma mark - WHRegisterDelegate
/**
 *  xmpp注册成功
 */
-(void)xmppDidRegisterSuccess{
    NSLog(@"通过注册界面，成功完成注册");
    //注册账号有两套，注册openfire成功后，立马发送注册web账号的请求
    [self webRegisterForServer];
    
//    [MBProgressHUD showSuccess:@"注册成功" toView:self.parentViewController.presentingViewController.view];
    [self backAction:nil];
}
/**
 *  xmpp注册失败
 */
-(void)xmppDidRegisterFailed{
    NSLog(@"在注册界面注册失败");
    [self sinaLogin];
//    [MBProgressHUD showError:@"注册失败"];
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
    
    [MBProgressHUD showSuccess:@"登录失败" toView:self.parentViewController.presentingViewController.view];
    [self dismissViewControllerAnimated:YES completion:nil];
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
