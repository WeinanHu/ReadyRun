//
//  UIImageView+WHRoundImage.m
//  酷跑
//
//  Created by Wayne on 16/5/17.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "UIImageView+WHRoundImage.h"

@implementation UIImageView (WHRoundImage)
- (void) setRoundLayer{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor  whiteColor].CGColor;
}
@end
