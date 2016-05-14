//
//  WHAddFriendController.m
//  酷跑
//
//  Created by Wayne on 16/5/13.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHAddFriendController.h"
#import "WHUserInfo.h"
#import "WHXMPPTool.h"
#import "MBProgressHUD+KR.h"
@interface WHAddFriendController ()
@property (weak, nonatomic) IBOutlet UITextField *friendNameField;

@end

@implementation WHAddFriendController
/**返回*/
- (IBAction)backAction:(id)sender {
    [self.navigationController  popViewControllerAnimated:YES];
}
/**添加按钮点击*/
- (IBAction)addFriendAction:(id)sender {
    NSString *friendName = self.friendNameField.text;
    //判断好友为自己时return
    if ([friendName isEqualToString:[WHUserInfo sharedWHUserInfo].userName]) {
        [MBProgressHUD showMessage:@"好友不能是自己"];
        return;
    }
    //判断好友已经存在时，return
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",friendName,WHXMPPDOMAIN];
    if ([[WHXMPPTool sharedWHXMPPTool].xmppRosterStorage userExistsWithJID:[XMPPJID jidWithString:jidStr] xmppStream:[WHXMPPTool sharedWHXMPPTool].xmppStream]) {
        [MBProgressHUD showMessage:@"好友已经存在"];
        
        return;
    }
    //最后添加这个人为好友
    [[WHXMPPTool sharedWHXMPPTool].xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:jidStr]];
    [MBProgressHUD showMessage:@"成功添加好友"];
    [self.navigationController  popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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
