//
//  UIView+YLExtension.h
//  0902百思不得姐
//
//  Created by 余亮 on 15/9/5.
//  Copyright (c) 2015年 余亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YLExtension)
@property(nonatomic,assign)CGFloat x ;
@property(nonatomic,assign)CGFloat y ;
@property(nonatomic,assign)CGFloat width ;
@property(nonatomic,assign)CGFloat height ;
@property(nonatomic,assign)CGFloat centerX ;
@property(nonatomic,assign)CGFloat centerY ;

+ (instancetype) viewFromXib;
@end
