//
//  WHMyMsgListController.m
//  酷跑
//
//  Created by Wayne on 16/5/17.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHMyMsgListController.h"
#import "XMPPMessage.h"
#import "WHUserInfo.h"
#import "WHXMPPTool.h"
#import "WHMyMsgListCell.h"
#import "XMPPvCardTemp.h"
#import "WHChatViewController.h"
@interface WHMyMsgListController ()
@property(nonatomic,strong) NSArray *mostRecentMsg;

@end

@implementation WHMyMsgListController
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMsg];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
/**
 *  加载信息
 */
-(void)loadMsg{
    NSManagedObjectContext *context = [[WHXMPPTool sharedWHXMPPTool].xmppMessageArchStorage mainThreadManagedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Contact_CoreDataObject"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[WHUserInfo sharedWHUserInfo].jidStr];
    request.predicate = pre;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:NO];
    request.sortDescriptors = @[sort];
    //获取数据

    NSError *error = nil;
    self.mostRecentMsg = [context executeFetchRequest:request error:&error];

    if (error) {
        MYLog(@"%@",error);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mostRecentMsg.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WHMyMsgListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myMsgCell" forIndexPath:indexPath];
    XMPPMessageArchiving_Contact_CoreDataObject *friend = self.mostRecentMsg[indexPath.row];
    cell.nameLabel.text = friend.bareJidStr;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    cell.dateLabel.text = [formatter stringFromDate:friend.mostRecentMessageTimestamp];
    id obj = [self uncodeWith64BaseString:friend.mostRecentMessageBody];
    if ([obj isKindOfClass:[UIImage class]]) {
        cell.msgLabel.text = @"图片";
    }else{
        cell.msgLabel.text = (NSString*)obj;
    }
    NSData *photo = [[WHXMPPTool sharedWHXMPPTool].xmppvAvatar photoDataForJID:friend.bareJid];
    if (photo) {
        cell.headImageView.image = [UIImage imageWithData:photo];
    }else{
        cell.headImageView.image = [UIImage imageNamed:@"微信"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XMPPMessageArchiving_Contact_CoreDataObject *friend = self.mostRecentMsg[indexPath.row];
    
    [self performSegueWithIdentifier:@"msgToChatSegue" sender:friend.bareJid];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[WHChatViewController class]]) {
        WHChatViewController *chatController = (WHChatViewController*)segue.destinationViewController;
        chatController.friendJid = sender;
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
