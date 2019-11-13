//
//  GridView.m
//  ChatNhanh
//
//  Created by Van Trieu Phu Huy on 8/7/18.
//  Copyright © 2018 Van Trieu Phu Huy. All rights reserved.
//

#import "GridView.h"
#import "UIView+SDAutoLayout.h"

#define kGridItemViewColor [[UIColor greenColor] colorWithAlphaComponent:0.5]


@implementation GridView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)handleTap:(UITapGestureRecognizer *)gesRecognizer {
    
}
    
- (void)removeAllSubviews {
    NSArray *arr = self.subviews;
    for (UIView *view in arr) {
        [view removeFromSuperview];
    }
}

- (void)addGridItemView:(UIView *)itemView andFloatLeft:(BOOL)isFloatLeft {
    itemView.sd_cornerRadius = @(6.0);
    itemView.layer.borderWidth = 0.4;
    itemView.layer.borderColor = [UIColor grayColor].CGColor;
    [self addSubview:itemView];
    
    __block UIView *lastView = self;
    __block BOOL _isFloatLeft = isFloatLeft;
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (idx < 3 && (idx == (self.subviews.count > 2 ? 2 : 1))) { // 如果idx等于当第一行最后一个view的index时开始设置一行等宽子view
            NSMutableArray *equalWidthSubviews = [NSMutableArray new];
            for (int i = 0; i <= idx; i++) {
                UIView *subview = self.subviews[i];
                [equalWidthSubviews addObject:subview];
                if (i == 0) {
                    /*// 设置一排等宽子view的第一个view的约束
                    if(_isFloatLeft) {
                        subview.sd_resetLayout
                        .leftSpaceToView(lastView, kGridItemViewMargin)
                        .topSpaceToView(lastView, kGridItemViewMargin)
                        .heightIs(kGridItemViewWidth);
                    } else {
                        subview.sd_resetLayout
                        .rightSpaceToView(lastView, kGridItemViewMargin)
                        .topSpaceToView(lastView, kGridItemViewMargin)
                        .heightIs(kGridItemViewWidth);
                    }
                    */
                } else if (i == idx) { // 设置一排等宽子view的中间view的约束
                    subview.sd_resetLayout
                    .leftSpaceToView(lastView, kGridItemViewMargin)
                    .topEqualToView(lastView)
                    .rightSpaceToView(self, kGridItemViewMargin)
                    .heightRatioToView(lastView, 1);
                    self.sd_equalWidthSubviews = [equalWidthSubviews copy];
                } else { // 设置一排等宽子view的最后一个view的约束
                    if(_isFloatLeft) {
                        subview.sd_resetLayout
                        .leftSpaceToView(lastView, kGridItemViewMargin)
                        .topEqualToView(lastView)
                        .heightIs(kGridItemViewWidth);
                    } else {
                        subview.sd_resetLayout
                        .rightSpaceToView(lastView, kGridItemViewMargin)
                        .topEqualToView(lastView)
                        .heightIs(kGridItemViewWidth);
                    }
                    
                    
                }
                lastView = subview;
            }
        } else if (idx > 2){ // 设置第一排之后的子view的的约束
            long lastViewIndex = idx - 3;
            lastView = self.subviews[lastViewIndex];
            view.sd_resetNewLayout
            .leftEqualToView(lastView)
            .rightEqualToView(lastView)
            .heightRatioToView(lastView, 1)
            .topSpaceToView(lastView, kGridItemViewMargin);
        } else if(idx == 0) {
            view.sd_resetNewLayout
            .leftSpaceToView(lastView, 0)
            .widthIs(kGridItemViewWidth)
            .heightIs(kGridItemViewWidth);
        }
    }];
}

- (void)addGridItemView:(BOOL)isFloatLeft {
    
    self.backgroundColor = [UIColor whiteColor];
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.sd_cornerRadius = @(6.0);
    view.layer.borderWidth = 0.4;
    view.layer.borderColor = [UIColor grayColor].CGColor;
    [self addSubview:view];
    
    __block UIView *lastView = self;
    __block BOOL _isFloatLeft = isFloatLeft;
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (idx < 3 && (idx == (self.subviews.count > 2 ? 2 : 1))) { // 如果idx等于当第一行最后一个view的index时开始设置一行等宽子view
            NSMutableArray *equalWidthSubviews = [NSMutableArray new];
            for (int i = 0; i <= idx; i++) {
                UIView *subview = self.subviews[i];
                [equalWidthSubviews addObject:subview];
                if (i == 0) { // 设置一排等宽子view的第一个view的约束
                    if(_isFloatLeft) {
                        subview.sd_resetLayout
                        .leftSpaceToView(lastView, kGridItemViewMargin)
                        .topSpaceToView(lastView, kGridItemViewMargin)
                        .heightIs(kGridItemViewWidth);
                    } else {
                        subview.sd_resetLayout
                        .rightSpaceToView(lastView, kGridItemViewMargin)
                        .topSpaceToView(lastView, kGridItemViewMargin)
                        .heightIs(kGridItemViewWidth);
                    }
                    
                } else if (i == idx) { // 设置一排等宽子view的中间view的约束
                    subview.sd_resetLayout
                    .leftSpaceToView(lastView, kGridItemViewMargin)
                    .topEqualToView(lastView)
                    .rightSpaceToView(self, kGridItemViewMargin)
                    .heightRatioToView(lastView, 1);
                    self.sd_equalWidthSubviews = [equalWidthSubviews copy];
                } else { // 设置一排等宽子view的最后一个view的约束
                    if(_isFloatLeft) {
                        subview.sd_resetLayout
                        .leftSpaceToView(lastView, kGridItemViewMargin)
                        .topEqualToView(lastView)
                        .heightIs(kGridItemViewWidth);
                    } else {
                        subview.sd_resetLayout
                        .rightSpaceToView(lastView, kGridItemViewMargin)
                        .topEqualToView(lastView)
                        .heightIs(kGridItemViewWidth);
                    }
                    
                    
                }
                lastView = subview;
            }
        } else if (idx > 2){ // 设置第一排之后的子view的的约束
            long lastViewIndex = idx - 3;
            lastView = self.subviews[lastViewIndex];
            view.sd_resetNewLayout
            .leftEqualToView(lastView)
            .rightEqualToView(lastView)
            .heightRatioToView(lastView, 1)
            .topSpaceToView(lastView, kGridItemViewMargin);
        }
    }];
    
    //[self setupAutoHeightWithBottomView:self.subviews.lastObject bottomMargin:2];
    
    /*
    __block UIView *lastView = self;
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (idx < 3 && (idx == (self.subviews.count > 2 ? 2 : 1))) { // 如果idx等于当第一行最后一个view的index时开始设置一行等宽子view
            NSMutableArray *equalWidthSubviews = [NSMutableArray new];
            for (int i = 0; i <= idx; i++) {
                UIView *subview = self.subviews[i];
                [equalWidthSubviews addObject:subview];
                if (i == 0) { // 设置一排等宽子view的第一个view的约束
                    subview.sd_resetLayout
                    .leftSpaceToView(lastView, 10)
                    .topSpaceToView(lastView, 10)
                    .heightIs(50);
                } else if (i == idx) { // 设置一排等宽子view的中间view的约束
                    subview.sd_resetLayout
                    .leftSpaceToView(lastView, 10)
                    .topEqualToView(lastView)
                    .rightSpaceToView(self, 10)
                    .heightRatioToView(lastView, 1);
                    self.sd_equalWidthSubviews = [equalWidthSubviews copy];
                } else { // 设置一排等宽子view的最后一个view的约束
                    subview.sd_resetLayout
                    .leftSpaceToView(lastView, 10)
                    .topEqualToView(lastView)
                    .heightIs(50);
                }
                lastView = subview;
            }
        } else if (idx > 2){ // 设置第一排之后的子view的的约束
            long lastViewIndex = idx - 3;
            lastView = self.subviews[lastViewIndex];
            
            view.sd_resetNewLayout
            .leftEqualToView(lastView)
            .rightEqualToView(lastView)
            .heightRatioToView(lastView, 1)
            .topSpaceToView(lastView, 10);
        }
    }];
    
    [self setupAutoHeightWithBottomView:self.subviews.lastObject bottomMargin:10];
    */
}

@end
