//
//  BGWebController.h
//  BusinessGo
//
//  Created by feitian on 2017/4/6.
//  Copyright © 2017年 com.Ideal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^webVCBackBlock)();
@interface BGWebController : UIViewController

@property (nonatomic,assign)BOOL showTitleString;//只显示上级界面传入的titleString 默认为NO

@property(nonatomic,strong)NSString *urlString;
@property(nonatomic,strong)NSString *titleString;
@property(nonatomic,strong)NSDictionary *notify;//卡片转提醒
//传入文件
@property(nonatomic,strong)NSData *Filelocaldata;
//文件路径，本地文件时必传
@property (nonatomic, copy)NSString *filePath;
@property (nonatomic,assign)BOOL showRightItem;//默认为NO，不显示导航栏右侧分享按钮
@property (nonatomic, copy)webVCBackBlock backBlock;

@property (nonatomic, copy)NSString *jsCommonStr;
-(void)refreshWebView;
@end
