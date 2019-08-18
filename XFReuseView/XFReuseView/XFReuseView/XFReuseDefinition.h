//
//  XFReuseDefinition.h
//  XFReuseView
//
//  Created by 谢帆 on 2018/8/17.
//  Copyright © 2018 谢帆. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    int row;
    int col;
} XFIndexPath;

XFIndexPath XFIndexPathMake(int row, int col);
BOOL XFIndexPathEquals(XFIndexPath indexPath, XFIndexPath otherIndexPath);
