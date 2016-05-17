//
//  WHUserInfo.h
//  酷跑
//
//  Created by Wayne on 16/5/10.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface WHUserInfo : NSObject
singleton_interface(WHUserInfo)
/**用户名*/
@property(nonatomic,copy) NSString *userName;
/**密码*/
@property(nonatomic,copy) NSString *userPassword;

/**注册的用户名*/
@property(nonatomic,copy) NSString *registerUserName;
/**注册的密码*/
@property(nonatomic,copy) NSString *registerPassword;
/**用来获取当前用户对应的jidStr*/
@property(nonatomic,strong) NSString *jidStr;

@end
