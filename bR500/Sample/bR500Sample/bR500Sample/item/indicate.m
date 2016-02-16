//
//  indicate.m
//  bR500Sample
//
//  Created by 彭珊珊 on 16/1/21.
//  Copyright © 2016年 ftsafe. All rights reserved.
//

#import "indicate.h"

@implementation indicate
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor lightGrayColor]];
        [self addIndicateView];
    }
    return self;
}

-(void)addIndicateView
{
    UIActivityIndicatorView *v  = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];//指定进度轮的大小
    [v setCenter:CGPointMake(self.center.x, self.center.y)];//指定进度轮中心点
    [v setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置进度轮显示类型
    [self  addSubview:v];
    [v startAnimating];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
