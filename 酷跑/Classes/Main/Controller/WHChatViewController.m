//
//  WHChatViewController.m
//  酷跑
//
//  Created by Wayne on 16/5/16.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHChatViewController.h"
#import "XMPPMessage.h"
#import "WHUserInfo.h"
#import "WHXMPPTool.h"
#import "WHMsgFriendCell.h"
#import "WHMsgMeCell.h"
#import "XMPPvCardTemp.h"
@interface WHChatViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *chatFileld;
@property (weak, nonatomic) IBOutlet UIButton *picButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property(nonatomic,strong) NSFetchedResultsController *fetchController;
@end

@implementation WHChatViewController
#pragma mark - Message
- (IBAction)sendTextMessage:(id)sender {
    NSString *msgStr = self.chatFileld.text;
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:[@"text:" stringByAppendingString:msgStr]];

    [[WHXMPPTool sharedWHXMPPTool].xmppStream sendElement:msg];
    
}
/**把二进制数据变成base64格式的字符串*/
-(void)sendImageMsg:(NSData*)data{
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:[@"image:" stringByAppendingString:base64Str]];
    
    [[WHXMPPTool sharedWHXMPPTool].xmppStream sendElement:msg];
}
/**
 *  加载信息
 */
-(void)loadMsg{
    NSManagedObjectContext *context = [[WHXMPPTool sharedWHXMPPTool].xmppMessageArchStorage mainThreadManagedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and bareJidStr = %@",[WHUserInfo sharedWHUserInfo].jidStr,[self.friendJid bare]];
    request.predicate = pre;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    //获取数据
    self.fetchController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchController.delegate = self;
    NSError *error = nil;
    [self.fetchController performFetch:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}
#pragma mark - button
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)clickPicButton:(id)sender {
    UIImagePickerController *imagepicker = [UIImagePickerController new];
    imagepicker.delegate = self;
    imagepicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagepicker.editing = NO;
    [self presentViewController:imagepicker animated:YES completion:nil];
}


#pragma mark - View
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];

    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self scrollToBottom:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}
/**
 *  滚动到消息最末端
 */
-(void)scrollToBottom:(BOOL)animated{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.fetchController.fetchedObjects.count-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}
-(void)openKeyboard:(NSNotification*)notification{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    self.bottomConstraint.constant = keyboardFrame.size.height;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToBottom:NO];
        });
    }];
    
}
-(void)closeKeyboard:(NSNotification*)notification{
    
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    self.bottomConstraint.constant = 0;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToBottom:NO];
        });
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",self.friendJid);
    [self setUpTableView];
    // Do any additional setup after loading the view.
}
-(void)setUpTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.974 green:0.853 blue:1.000 alpha:1.000];
    [self loadMsg];
//    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture)]];
}



//-(void)tapGesture{
//    
//}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    UIImage *newImage = [image thumbNailWithSize:CGSizeMake(200, 200)];
    NSData *data = UIImageJPEGRepresentation(newImage,0.7);
    [self sendImageMsg:data];
    NSLog(@"size = %ld",UIImagePNGRepresentation(image).length);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UITableViewDelegate & UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fetchController.fetchedObjects.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XMPPMessageArchiving_Message_CoreDataObject *msgObj = self.fetchController.fetchedObjects[indexPath.row];
    if (msgObj.isOutgoing) {
        WHMsgMeCell *meCell = [tableView dequeueReusableCellWithIdentifier:@"meCell"];
        NSData *photo = [WHXMPPTool sharedWHXMPPTool].xmppvCard.myvCardTemp.photo;
        if (photo) {
            meCell.headImageView.image = [UIImage imageWithData:photo];
        }else{
            meCell.headImageView.image = [UIImage imageNamed:@"微信"];
        }
        [meCell.headImageView setRoundLayer];
        meCell.userNameLabel.text = [WHUserInfo sharedWHUserInfo].userName;
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        meCell.selectionStyle = UITableViewCellSelectionStyleNone;
        meCell.msgTimeLabel.text = [formatter stringFromDate:msgObj.timestamp];
        //解决复用问题
        meCell.msgLabel.attributedText = nil;
        for (id obj in meCell.msgLabel.subviews) {
            [obj removeFromSuperview];
        }
        //解码发送内容
        id obj = [self uncodeWith64BaseString:msgObj.body];
        if ([obj isKindOfClass:[NSString class]]) {
            meCell.msgLabel.text = (NSString*)obj;
        }else if([obj isKindOfClass:[UIImage class]]){
            UIImage *image = (UIImage*)obj;
            NSTextAttachment *attachment = [NSTextAttachment new];
            attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
            NSAttributedString *attributeStr = [NSAttributedString attributedStringWithAttachment:attachment];
            meCell.msgLabel.attributedText = attributeStr;
            [meCell.msgLabel addSubview:[[UIImageView alloc]initWithImage:image]];
        }else{
            meCell.msgLabel.text = (NSString*)obj;
        }
        
        
        return  meCell;
    }else{
        WHMsgFriendCell *friendCell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
        NSData *photo = [[WHXMPPTool sharedWHXMPPTool].xmppvAvatar photoDataForJID:self.friendJid];
        if (photo) {
            friendCell.headImageView.image = [UIImage imageWithData:photo];
        }else{
            friendCell.headImageView.image = [UIImage imageNamed:@"微信"];
        }
        [friendCell.headImageView setRoundLayer];
        friendCell.userNameLabel.text = self.friendJid.user;
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
        friendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        friendCell.msgTimeLabel.text = [formatter stringFromDate:msgObj.timestamp];
        //解决复用问题
        friendCell.msgLabel.attributedText = nil;
        for (id obj in friendCell.msgLabel.subviews) {
            [obj removeFromSuperview];
        }
        //解码发送内容
        id obj = [self uncodeWith64BaseString:msgObj.body];
        if ([obj isKindOfClass:[NSString class]]) {
            friendCell.msgLabel.text = (NSString*)obj;
        }else if([obj isKindOfClass:[UIImage class]]){
            NSTextAttachment *attachment = [NSTextAttachment new];
            UIImage *image = (UIImage*)obj;
            attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
            NSAttributedString *attributeStr = [NSAttributedString attributedStringWithAttachment:attachment];
            friendCell.msgLabel.attributedText = attributeStr;
            [friendCell.msgLabel addSubview:[[UIImageView alloc]initWithImage:image]];
        }else{
            friendCell.msgLabel.text = (NSString*)obj;
        }
        return  friendCell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}
#pragma mark - NSFetchedResultsControllerDelegate
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
    [self scrollToBottom:YES];
}
#pragma mark - other
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
