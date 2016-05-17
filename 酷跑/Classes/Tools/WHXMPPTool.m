//
//  WHXMPPTool.m
//  酷跑
//
//  Created by Wayne on 16/5/10.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHXMPPTool.h"
#import "WHUserInfo.h"

typedef enum {
    LOGIN,
    REGISTER
}CONNECT_TYPE;
@interface WHXMPPTool()<XMPPStreamDelegate,XMPPRosterDelegate>
@property(nonatomic,assign) CONNECT_TYPE connectType;
@property(nonatomic,strong) XMPPJID *fJid;

@end
@implementation WHXMPPTool
singleton_implementation(WHXMPPTool);
/**外部登录接口*/
-(void)userLogin{
    self.connectType = LOGIN;
    [self connectToServer];
}

/**外部注册接口*/
-(void)userRegister{
    self.connectType = REGISTER;
    [self connectToServer];
}

/**准备一些数据 设置流 设置代理*/
-(void)setUpXmppStream{
    self.xmppStream = [XMPPStream new];
    //设置代理
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //设置电子名片模块
    self.xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCard = [[XMPPvCardTempModule alloc]initWithvCardStorage:self.xmppvCardStorage];
    //设置头像模块
    self.xmppvAvatar = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:self.xmppvCard];
    //设置花名册模块
    self.xmppRosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
    self.xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:self.xmppRosterStorage];
    //增加代理
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //给消息模块赋值
    self.xmppMessageArchStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    self.xmppMessageArch = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:self.xmppMessageArchStorage];
    //激活电子名片模块，（激活后沙盒中才有数据库文件）
    [self.xmppvCard activate:self.xmppStream];
    //激活头像模块
    [self.xmppvAvatar activate:self.xmppStream];
    
    //激活花名册模块
    [self.xmppRoster activate:self.xmppStream];
    //激活消息模块
    [self.xmppMessageArch activate:self.xmppStream];
}
/**连接服务器*/
-(void)connectToServer{
    //先把之前的连接断开
    [self.xmppStream disconnect];
    
    if (self.xmppStream == nil) {
        [self setUpXmppStream];
    }
    self.xmppStream.hostName = WHXMPPHOSTNAME;
    self.xmppStream.hostPort = WHXMPPPORT;
    /**构建jid*/
    NSString *userName = nil;
    if (self.connectType ==LOGIN) {
        
        userName = [WHUserInfo sharedWHUserInfo].userName;
    }else{
        userName = [WHUserInfo sharedWHUserInfo].registerUserName;
    }
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",userName,WHXMPPDOMAIN];
    self.xmppStream.myJID = [XMPPJID jidWithString:jidStr];
    //连接服务器
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"%@",error.userInfo);
    }
    
    
}
/**发送密码 进行授权*/
-(void)sendPassword{
    NSString *userPassword = nil;
    NSError *error = nil;
    if (self.connectType == LOGIN) {
        userPassword = [WHUserInfo sharedWHUserInfo].userPassword;
        //使用密码进行授权
        [self.xmppStream authenticateWithPassword:userPassword error:&error];
        
    }else{
        userPassword = [WHUserInfo sharedWHUserInfo].registerPassword;
        //使用密码进行注册
        [self.xmppStream registerWithPassword:userPassword error:&error];
    }
    if (error) {
        NSLog(@"%@",error.userInfo);
    }
}
/**发送在线消息*/
-(void)sendOnLine{
    //这个对象默认代表在线
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
}
#pragma mark - XMPPStreamDelegate
//连接成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"连接成功");
    [self sendPassword];
}
//连接失败
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    if (error) {
        if (self.connectType == LOGIN) {
            [self.loginDelegate xmppConnectError];
        }else{
            [self.registerDelegate xmppConnectError];
        }
        NSLog(@"断开和服务器的连接:%@",error.userInfo);
    }
}
//授权成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"授权成功");
    [self sendOnLine];
    [self.loginDelegate xmppDidLoginSuccess];
}
//授权失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"授权失败:%@",error);
    [self.loginDelegate xmppDidLoginFailed];
}
//注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功");
    [self.registerDelegate xmppDidRegisterSuccess];
}
//注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    NSLog(@"注册失败");
    [self.registerDelegate xmppDidRegisterFailed];
}

#pragma mark - XMPPRosterDelegate

-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSLog(@"-----presenceType:%@",presenceType);
    
    NSLog(@"-----presence2:%@  sender2:%@",presence,sender);
    NSLog(@"-----fromUser:%@",presenceFromUser);
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",presenceFromUser,WHXMPPDOMAIN];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    self.fJid = jid;
    UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:[NSString stringWithFormat:@"%@想申请加好友",jidStr] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"同意并添加对方为好友", @"同意",nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index====%ld",buttonIndex);
    if (0 == buttonIndex) {
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fJid andAddToRoster:YES];
    }else if(1== buttonIndex){
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fJid andAddToRoster:NO];
    }else if(2== buttonIndex){
        
        
        [self.xmppRoster  rejectPresenceSubscriptionRequestFrom:self.fJid];

    }
}
@end
