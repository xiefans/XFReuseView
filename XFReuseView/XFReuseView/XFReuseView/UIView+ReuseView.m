//
//  UIView+ReuseView.m
//  XFReuseView
//
//  Created by 谢帆 on 2019/8/18.
//  Copyright © 2019 谢帆. All rights reserved.
//

#import "UIView+ReuseView.h"
#import <objc/runtime.h>

@implementation UIView (ReuseView)

- (void)setIdentification:(NSString *)identification {
    objc_setAssociatedObject(self, @selector(setIdentification:), identification, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)identification {
    return objc_getAssociatedObject(self, @selector(setIdentification:));
}

@end
