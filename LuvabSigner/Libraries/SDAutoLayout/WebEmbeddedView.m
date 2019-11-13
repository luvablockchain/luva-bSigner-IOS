//
//  WebEmbeddedView.m
//  ChatNhanh
//
//  Created by Van Trieu Phu Huy on 10/5/18.
//  Copyright © 2018 Van Trieu Phu Huy. All rights reserved.
//

#import "WebEmbeddedView.h"
#import "UIView+SDAutoLayout.h"

@implementation WebEmbeddedView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)addView:(UIView *)mainView andTitleView:(UIView *)titleView andSubtitleView:(UIView *)subtitleView andInfoView:(UIView *)infoView andIcon:(UIView *)iconView andDict:(NSDictionary *)dict {
    
    CGFloat height = [[dict objectForKey:@"1"] floatValue];
    [self addSubview:mainView];
    mainView.sd_layout
    .leftSpaceToView(self, 0)
    .topSpaceToView(self, 0)
    .rightSpaceToView(self, 0)
    .heightIs(height);
    //.heightIs(120);
    
    height = [[dict objectForKey:@"2"] floatValue];
    if(height > 34) {
        height = 34;
    }
    [self addSubview:titleView];
    titleView.sd_layout
    .leftSpaceToView(self, 8)
    .topSpaceToView(mainView, 3)
    .rightSpaceToView(self, 8)
    .heightIs(height);
    //.heightIs(34);
    
    height = [[dict objectForKey:@"3"] floatValue];
    if(height > 78) {
        height = 78;
    }
    [self addSubview:subtitleView];
    subtitleView.sd_layout
    .leftSpaceToView(self, 8)
    .topSpaceToView(titleView, 0)
    .rightSpaceToView(self, 8)
    //.bottomSpaceToView(self, 27)
    .heightIs(height);
    
    height = [[dict objectForKey:@"4"] floatValue];
    UIView *containInfoView = [[UIView alloc] init];
    [self addSubview:containInfoView];
    containInfoView.sd_layout
    .leftSpaceToView(self, 8)
    .topSpaceToView(subtitleView, 0)
    .rightSpaceToView(self, 8)
    .bottomSpaceToView(self, 5)
    .heightIs(height);
    //.heightIs(20);
    
    [containInfoView addSubview:iconView];
    iconView.sd_layout
    .leftSpaceToView(containInfoView, 0)
    .topSpaceToView(containInfoView, 3)
    .heightIs(14)
    .widthIs(14);
    
    [containInfoView addSubview:infoView];
    infoView.sd_layout
    .leftSpaceToView(iconView, 3)
    .topSpaceToView(containInfoView, 0)
    .rightSpaceToView(containInfoView, 0)
    .heightIs(20);
    
    
}

- (void)removeAllSubviews {
    NSArray *arr = self.subviews;
    for (UIView *view in arr) {
        [view removeFromSuperview];
    }
}

@end
