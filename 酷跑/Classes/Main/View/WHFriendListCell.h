//
//  WHFriendListCell.h
//  酷跑
//
//  Created by Wayne on 16/5/13.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHFriendListCell : UITableViewCell
/**好友头像*/
@property (weak, nonatomic) IBOutlet UIImageView *friendImageView;
/**好友名字*/
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
/**好友状态*/
@property (weak, nonatomic) IBOutlet UILabel *friendStutasLabel;

@end
