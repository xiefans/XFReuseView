//
//  XFReuseView.h
//  XFReuseView
//
//  Created by 谢帆 on 2018/8/17.
//  Copyright © 2018 谢帆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XFReuseDefinition.h"
#import "UIView+ReuseView.h"

FOUNDATION_EXPORT CGFloat const XFReuseViewFixSuperView;

typedef NS_ENUM(NSInteger , XFReuseViewScrollDirection) {
    XFReuseViewScrollDirectionVertical,
    XFReuseViewScrollDirectionHorizontal
};

@class XFReuseView;
@protocol XFReuseViewDataSource <NSObject>

- (__kindof UIView *)reuseView:(XFReuseView *)reuseView itemViewAtIndexPath:(NSInteger)indexPath;
- (NSInteger)numberOfReuseView:(XFReuseView *)reuseView;

@optional
- (CGSize)reuseView:(XFReuseView *)reuseView itemViewSizeAtIndexPath:(NSInteger)indexPath;

@end

@protocol XFReuseViewDelegate <UIScrollViewDelegate>

@optional
- (void)reuseView:(XFReuseView *)reuseView didActionAtIndexPath:(NSInteger)indexPath;
- (void)reuseView:(XFReuseView *)reuseView scrollViewPageEndAtPage:(NSInteger)page;
- (void)reuseView:(XFReuseView *)reuseView itemView:(__kindof UIView *)itemView layoutWithFrame:(CGRect)itemFrame;

@end


@interface XFReuseView : UIScrollView

@property (nonatomic, weak) id<XFReuseViewDataSource> dataSource;
@property (nonatomic, weak) id<XFReuseViewDelegate> delegate;

@property (nonatomic, assign)XFReuseViewScrollDirection scrollDirection;

- (__kindof UIView *)dequeueReusableItemWithIdentifier:(NSString *)identifier;
- (__kindof UIView *)itemViewAtIndexPath:(NSInteger)indexPath;
- (NSInteger)indexPathForItemView:(UIView *)itemView;

- (void)reloadData;

@end
