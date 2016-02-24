//
//  YLAlertView.h
//  imitateAliScan
//
//  Created by 余亮 on 16/2/24.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLAlertView : UIView
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

- (instancetype) initAlert ;

+ (instancetype) defaultAlert ;

@end
