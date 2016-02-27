//
//  YLAlertView.h
//  imitateAliScan
//
//  Created by 余亮 on 16/2/24.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol YLAlertViewWithDelegate <NSObject>

@required
- (void) YLAlertViewBackClick ;
- (void) YLAlertGoOnClick ;
@end

@interface YLAlertView : UIView
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property(nonatomic,weak)id<YLAlertViewWithDelegate>delegate ;
- (instancetype) initAlert ;

+ (instancetype) defaultAlert ;

@end
