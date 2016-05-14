//
//  WHEditViewController.m
//  酷跑
//
//  Created by Wayne on 16/5/12.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHEditViewController.h"
#import "WHXMPPTool.h"
#import "WHUserInfo.h"
#import "XMPPvCardTemp.h"
@interface WHEditViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nickNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@end

@implementation WHEditViewController
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveInfoAction:(id)sender {
    XMPPvCardTemp *myInfo = [WHXMPPTool sharedWHXMPPTool].xmppvCard.myvCardTemp;
    //昵称和邮件
    myInfo.nickname = self.nickNameField.text;
    myInfo.mailer = self.emailField.text;
    //头像数据
    myInfo.photo = UIImagePNGRepresentation(self.headerImageView.image);
    //更新
    [[WHXMPPTool sharedWHXMPPTool].xmppvCard updateMyvCardTemp:myInfo];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setUpInfo{
    XMPPvCardTemp *vCardTemp =[WHXMPPTool sharedWHXMPPTool].xmppvCard.myvCardTemp;
    if (vCardTemp.photo) {
        self.headerImageView.image = [UIImage imageWithData:vCardTemp.photo];
    }else{
        self.headerImageView.image = [UIImage imageNamed:@"微博"];
    }
    
    self.nickNameField.text = vCardTemp.nickname;
    self.emailField.text = vCardTemp.mailer;
    //增加手势识别
    self.headerImageView.userInteractionEnabled = YES;
    [self.headerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerImageViewTap)]];
}
-(void)headerImageViewTap{
    MYLog(@"点击imageView");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //判断camera是否有效
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imageControl = [UIImagePickerController new];
            imageControl.delegate = self;
            imageControl.sourceType = UIImagePickerControllerSourceTypeCamera;
            imageControl.allowsEditing = YES;
            [self presentViewController:imageControl animated:YES completion:nil];
        }
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imageControl = [UIImagePickerController new];
        imageControl.delegate = self;
        imageControl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imageControl.allowsEditing = YES;
        [self presentViewController:imageControl animated:YES completion:nil];
        
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [self presentViewController:alert animated:YES completion:nil];
//    UIActionSheet *sht = [[UIActionSheet alloc]initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相机" otherButtonTitles:@"相册", nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpInfo];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.headerImageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
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
