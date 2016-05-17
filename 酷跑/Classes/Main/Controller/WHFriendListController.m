//
//  WHFriendListController.m
//  酷跑
//
//  Created by Wayne on 16/5/13.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHFriendListController.h"
#import "WHXMPPTool.h"
#import "WHUserInfo.h"
#import "WHFriendListCell.h"
#import "WHChatViewController.h"
@interface WHFriendListController ()<NSFetchedResultsControllerDelegate>
/**存放好友的数组*/
//@property(nonatomic,strong) NSArray *friends;
//结果集控制器
@property(nonatomic,strong) NSFetchedResultsController *fetchController;
@end

@implementation WHFriendListController
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.autoresizesSubviews = YES;
    [self loadFriend];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
/**加载好友*/
//-(void)loadFriend{
//    //获得上下文
//    NSManagedObjectContext *context = [[WHXMPPTool sharedWHXMPPTool].xmppRosterStorage mainThreadManagedObjectContext];
//    //NSFetchRequest 关联实体
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
//    
//    //设置谓词 NSPredicate
//    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",[WHUserInfo sharedWHUserInfo].userName,WHXMPPDOMAIN];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",jidStr];
//    request.predicate = predicate;
//    //设置排序
//    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
//    request.sortDescriptors = @[sortDes];
//    //获取数据
//    NSError *error = nil;
//    self.friends = [context executeFetchRequest:request error:&error];
//    if (error) {
//        MYLog(@"%@",error);
//    }
//}

/**加载好友*/
-(void)loadFriend{
    //获得上下文
    NSManagedObjectContext *context = [[WHXMPPTool sharedWHXMPPTool].xmppRosterStorage mainThreadManagedObjectContext];
    //NSFetchRequest 关联实体
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //设置谓词 NSPredicate
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",[WHUserInfo sharedWHUserInfo].userName,WHXMPPDOMAIN];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@",jidStr];
    request.predicate = predicate;
    //设置排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sortDes];
    //获取数据
    NSError *error = nil;
    self.fetchController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchController.delegate = self;
    [self.fetchController performFetch:&error];
//    self.friends = [context executeFetchRequest:request error:&error];
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
    return self.fetchController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WHFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendListCell" forIndexPath:indexPath];
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    //好友名字
    cell.friendNameLabel.text = friend.displayName;
    //好友状态 0 -在线  1-离开 2-离线
    NSLog(@"%@:%d",cell.friendNameLabel.text,[friend.sectionNum intValue]);
    switch ([friend.sectionNum intValue]) {
        case 0:
            cell.friendStutasLabel.text = @"在线";
            cell.friendStutasLabel.textColor = [UIColor colorWithRed:0.294 green:0.826 blue:0.173 alpha:1.000];
            break;
        case 1:
            cell.friendStutasLabel.text = @"离开";
            cell.friendStutasLabel.textColor = [UIColor colorWithRed:0.600 green:0.427 blue:0.826 alpha:1.000];
            break;
        default:
            cell.friendStutasLabel.text = @"离线";
            cell.friendStutasLabel.textColor = [UIColor colorWithRed:0.743 green:0.826 blue:0.754 alpha:1.000];
            break;
    }
    
    //头像数据需要使用头像模块来获取
    NSData *data = [[WHXMPPTool sharedWHXMPPTool].xmppvAvatar photoDataForJID:friend.jid];
    if (data) {
        cell.friendImageView.image = [UIImage imageWithData:data];
    }else{
        cell.friendImageView.image = [UIImage imageNamed:@"微博"];
    }
    
    
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [[WHXMPPTool sharedWHXMPPTool].xmppRoster removeUser:friend.jid];
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"chatSegue" sender:friend.jid];
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

#pragma mark - NSFetchedResultsControllerDelegate
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
}
//- (NSArray *)friends {
//	if(_friends == nil) {
//		_friends = [[NSArray alloc] init];
//	}
//	return _friends;
//}

@end
