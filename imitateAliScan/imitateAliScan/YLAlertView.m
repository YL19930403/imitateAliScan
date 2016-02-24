//
//  YLAlertView.m
//  imitateAliScan
//
//  Created by 余亮 on 16/2/24.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import "YLAlertView.h"

@interface YLAlertView ()



@end

@implementation YLAlertView

- (instancetype)initAlert
{
    if (self == [super init]) {
        
    }
    return self ;
}


+ (instancetype)defaultAlert
{
    return  [[self alloc] initAlert];
}



- (void)awakeFromNib
{
    self.layer.cornerRadius = 8 ;
    self.layer.masksToBounds = YES ;
    self.contentLabel.numberOfLines = 0 ;
    self.contentLabel.userInteractionEnabled = YES ;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [self.contentLabel addGestureRecognizer:tap] ;
}

- (void) labelTapped :(UITapGestureRecognizer *)tap
{
    NSString * urlAddress = self.contentLabel.text ;
    NSURL * url = [NSURL URLWithString:urlAddress];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }else{
        NSLog(@"发送未知错误");
    }
    [self removeFromSuperview];
}

- (IBAction)exit:(UIButton *)sender {

    [self removeFromSuperview];
   
}

- (IBAction)AgainScanning:(UIButton *)sender {
    
}

- (IBAction)open:(UIButton *)sender {
}

@end















