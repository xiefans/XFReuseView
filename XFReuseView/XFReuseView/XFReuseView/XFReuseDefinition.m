//
//  XFReuseDefinition1.h
//  XFReuseView
//
//  Created by 谢帆 on 2019/8/17.
//  Copyright © 2019 谢帆. All rights reserved.
//

#import "XFReuseDefinition.h"

XFIndexPath XFIndexPathMake(int row, int col) {
    XFIndexPath indexPath = {row, col};
    indexPath.row = row;
    indexPath.col = col;
    return indexPath;
}

BOOL XFIndexPathEquals(XFIndexPath indexPath, XFIndexPath otherIndexPath) {
    if (indexPath.row == otherIndexPath.row && indexPath.col == otherIndexPath.col) {
        return YES;
    } else {
        return NO;
    }
}
