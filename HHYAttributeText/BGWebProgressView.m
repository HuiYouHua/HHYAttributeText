//
//  BGWebProgressView.m
//  hfj
//
//  Created by feitian on 2018/7/11.
//  Copyright © 2018年 feitian. All rights reserved.
//

#import "BGWebProgressView.h"
#import "UIView+BGExtension.h"
#import "YYKit.h"
@interface BGWebProgressView ()
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,assign)NSUInteger timeCount;

@end

@implementation BGWebProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.hidden = YES;
    self.backgroundColor = [UIColor whiteColor];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    self.backgroundColor = lineColor;
}

-(void)startLoadingAnimation{
    [self.superview bringSubviewToFront:self];
    self.hidden = NO;
    self.width = 0.0;
    
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:0.4 animations:^{
        weakSelf.width = kScreenWidth * 0.6;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            weakSelf.width = kScreenWidth * 0.8;
        }];
    }];
}

-(void)endLoadingAnimation{
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.width = kScreenWidth;
    } completion:^(BOOL finished) {
        weakSelf.width = 0.0;
        weakSelf.hidden = YES;
    }];
}

@end
