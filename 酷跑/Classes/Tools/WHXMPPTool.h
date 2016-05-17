//
//  WHXMPPTool.h
//  酷跑
//
//  Created by Wayne on 16/5/10.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "Singleton.h"
//#import "XMPPvCardTempModule.h"
@protocol WHLoginDelegate <NSObject>
-(void)xmppDidLoginSuccess;
-(void)xmppDidLoginFailed;
@optional
-(void)xmppConnectError;

@end
@protocol WHRegisterDelegate <NSObject>

-(void)xmppDidRegisterSuccess;
-(void)xmppDidRegisterFailed;
@optional
-(void)xmppConnectError;

@end
@interface WHXMPPTool : NSObject
/**定义xmpp流*/
@property(nonatomic,strong) XMPPStream *xmppStream;
/**定义电子名片模块和存储*/
@property(nonatomic,strong) XMPPvCardTempModule *xmppvCard;
@property(nonatomic,strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property(nonatomic,strong) XMPPvCardAvatarModule *xmppvAvatar;
@property(nonatomic,weak) id<WHLoginDelegate> loginDelegate;
@property(nonatomic,weak) id<WHRegisterDelegate> registerDelegate;

/**增加好友（花名册）模块和对应存储*/
@property(nonatomic,strong) XMPPRoster *xmppRoster;
@property(nonatomic,strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
/**消息模块和对应存储*/
@property(nonatomic,strong) XMPPMessageArchiving *xmppMessageArch;
@property(nonatomic,strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchStorage;
/**登录接口*/
-(void)userLogin;
/**公开注册接口*/
-(void)userRegister;
singleton_interface(WHXMPPTool);
@end
