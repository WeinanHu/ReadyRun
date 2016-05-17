//
//  WHMyProfileViewController.m
//  酷跑
//
//  Created by Wayne on 16/5/12.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHMyProfileViewController.h"
#import "WHXMPPTool.h"
#import "WHUserInfo.h"
#import "XMPPvCardTemp.h"
@interface WHMyProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation WHMyProfileViewController

- (IBAction)modifyUserInfo:(id)sender {
}
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    XMPPvCardTemp *vCardTemp =[WHXMPPTool sharedWHXMPPTool].xmppvCard.myvCardTemp;
    if (vCardTemp.photo) {
        self.imageView.image = [UIImage imageWithData:vCardTemp.photo];
    }else{
        self.imageView.image = [UIImage imageNamed:@"微博"];
    }
    self.userIDLabel.text = [WHUserInfo sharedWHUserInfo].userName;
    self.nickNameLabel.text = vCardTemp.nickname;
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
