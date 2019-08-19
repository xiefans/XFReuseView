//
//  ViewController.m
//  XFReuseView
//
//  Created by 谢帆 on 2019/8/17.
//  Copyright © 2019 谢帆. All rights reserved.
//

#import "ViewController.h"
#import "XFReuseView.h"

@interface ViewController () <XFReuseViewDelegate, XFReuseViewDataSource>

/**  */
@property (nonatomic, strong) XFReuseView *reuseView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.reuseView];
    [self.reuseView reloadData];
}

- (void)reuseView:(XFReuseView *)reuseView didActionAtIndexPath:(NSInteger)indexPath {
    NSLog(@"%ld", indexPath);
}

- (void)reuseView:(XFReuseView *)reuseView scrollViewPageEndAtPage:(NSInteger)page {
    CGRect frame = reuseView.frame;
    frame.size.height = 50.f * (page + 1);
    
    [UIView animateWithDuration:0.15 animations:^{
       reuseView.frame = frame;
    }];
}

- (CGSize)reuseView:(XFReuseView *)reuseView itemViewSizeAtIndexPath:(NSInteger)indexPath {
    return CGSizeMake(XFReuseViewFixSuperView, 50.f * (indexPath + 1));
}

- (NSInteger)numberOfReuseView:(XFReuseView *)reuseView {
    return 8;
}

- (UIView *)reuseView:(XFReuseView *)reuseView itemViewAtIndexPath:(NSInteger)indexPath {
    UILabel *view = [reuseView dequeueReusableItemWithIdentifier:@"temp"];
    
    if (!view) {
        view = [[UILabel alloc] init];
        view.identification = @"temp";
        view.textColor = [UIColor whiteColor];
        view.textAlignment = NSTextAlignmentCenter;
        view.userInteractionEnabled = YES;
    }
    
    view.text = [NSString stringWithFormat:@"%ld", indexPath];
    
    if (indexPath % 2 == 0) {
        view.backgroundColor = [UIColor lightGrayColor];
    } else {
        view.backgroundColor = [UIColor lightGrayColor];
    }
    
    return view;
}

- (XFReuseView *)reuseView {
    if (!_reuseView) {
        _reuseView = [[XFReuseView alloc] initWithFrame:CGRectMake(0., 49.f, 375, 603)];
        _reuseView.scrollDirection = XFReuseViewScrollDirectionHorizontal;
        _reuseView.delegate = self;
        _reuseView.dataSource = self;
        _reuseView.pagingEnabled = YES;
        _reuseView.backgroundColor = [UIColor lightGrayColor];
    }
    return _reuseView;
}

@end
