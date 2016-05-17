//
//  WHUserInfo.m
//  酷跑
//
//  Created by Wayne on 16/5/10.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHUserInfo.h"


@implementation WHUserInfo
singleton_implementation(WHUserInfo);
-(NSString *)jidStr{
    return [NSString stringWithFormat:@"%@@%@",self.userName,WHXMPPDOMAIN];
}
@end
