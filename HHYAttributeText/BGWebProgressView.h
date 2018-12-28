//
//  BGWebProgressView.h
//  hfj
//
//  Created by feitian on 2018/7/11.
//  Copyright © 2018年 feitian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGWebProgressView : UIView

//进度条颜色
@property (nonatomic,strong) UIColor  *lineColor;

//开始加载
-(void)startLoadingAnimation;

//结束加载
-(void)endLoadingAnimation;

@end
