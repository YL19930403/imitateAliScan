//
//  UIView+YLExtension.m
//  0902百思不得姐
//
//  Created by 余亮 on 15/9/5.
//  Copyright (c) 2015年 余亮. All rights reserved.
//

#import "UIView+YLExtension.h"

@implementation UIView (YLExtension)

//x的set方法
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame ;
    frame.origin.x = x ;
    self.frame = frame;
}

//x的get方法
- (CGFloat) x
{
    return self.frame.origin.x;
}


- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame ;
    frame.origin.y = y ;
    self.frame = frame;
}

- (CGFloat) y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame ;
    frame.size.width = width ;
    self.frame = frame;
}

- (CGFloat) width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame ;
    frame.size.height = height ;
    self.frame = frame;
}

- (CGFloat) height
{
    return self.frame.size.height;
}

- (void) setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center ;
    center.x = centerX;
    self.center = center;
}

- (CGFloat) centerX
{
    return  self.center.x;
}

- (void) setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center ;
    center.y = centerY;
    self.center = center;
}

- (CGFloat) centerY
{
    return  self.center.y;
}

//从Xib中创建一个控件,自动从Xib中加载跟它类名一样的Xib文件
+ (instancetype) viewFromXib
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil] lastObject];
}
@end











