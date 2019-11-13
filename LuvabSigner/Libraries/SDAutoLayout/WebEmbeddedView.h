//
//  WebEmbeddedView.h
//  ChatNhanh
//
//  Created by Van Trieu Phu Huy on 10/5/18.
//  Copyright © 2018 Van Trieu Phu Huy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebEmbeddedView : UIView

- (void)addView:(UIView *)mainView andTitleView:(UIView *)titleView andSubtitleView:(UIView *)subtitleView andInfoView:(UIView *)infoView andIcon:(UIView *)iconView andDict:(NSDictionary *)dict;

- (void)removeAllSubviews;

@end
