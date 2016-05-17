//
//  NSObject+WHBase64Uncode.m
//  酷跑
//
//  Created by Wayne on 16/5/17.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "NSObject+WHBase64Uncode.h"

@implementation NSObject (WHBase64Uncode)
/**
 *  base64解析
 *
 *  @param base64String base64码
 *
 *  @return prefix如果是text:，返回NSString,如果是image:,返回UIImage。
 */
-(id)uncodeWith64BaseString:(NSString*)base64String{
    if ([base64String hasPrefix:@"text:"]) {
        return [base64String substringFromIndex:5];
    }else if([base64String hasPrefix:@"image:"]){
        NSData *data = [[NSData alloc]initWithBase64EncodedString:[base64String substringFromIndex:6] options:0];
        
        UIImage *image = [UIImage imageWithData:data];
        return image;
        
    }else{
        return base64String;
    }
}
@end
