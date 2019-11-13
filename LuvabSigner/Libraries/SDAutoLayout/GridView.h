//
//  GridView.h
//  ChatNhanh
//
//  Created by Van Trieu Phu Huy on 8/7/18.
//  Copyright © 2018 Van Trieu Phu Huy. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kGridItemViewMargin 2.0

#define kGridItemViewWidth 70.0

@interface GridView : UIView

- (void)addGridItemView:(BOOL)isFloatLeft;

- (void)addGridItemView:(UIView *)itemView andFloatLeft:(BOOL)isFloatLeft;
    
- (void)removeAllSubviews;

@end
