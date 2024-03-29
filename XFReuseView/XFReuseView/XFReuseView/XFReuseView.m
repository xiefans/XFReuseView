//
//  XFReuseView.m
//  XFReuseView
//
//  Created by 谢帆 on 2018/8/17.
//  Copyright © 2018 谢帆. All rights reserved.
//

#import "XFReuseView.h"

CGFloat const XFReuseViewFixSuperView = -0.387;

typedef struct {
    unsigned didActionAtIndexPath : 1;
    unsigned scrollViewPageEndAtPage : 1;
    unsigned itemViewLayoutWithFrame : 1;
} RespondsOfDelegate;

typedef struct {
    unsigned itemViewAtIndexPath : 1;
    unsigned numberOfReuseView : 1;
    unsigned itemViewSizeAtIndexPath : 1;
} RespondsOfDataSource;

@interface XFReuseView ()

/** 复用池 */
@property (nonatomic, strong) NSMutableDictionary *reusePool;
/** 显示池， key 为位置 */
@property (nonatomic, strong) NSMutableDictionary *showPool;
/** 总数 */
@property (nonatomic, assign) NSInteger number;

/** 显示的页数 */
@property (nonatomic, assign)NSInteger showPage;

@end

@implementation XFReuseView {
    RespondsOfDelegate *_respondsOfDelegate;
    RespondsOfDataSource *_respondsOfDataSource;
}

@synthesize delegate = _delegate;

#pragma mark - Overrides
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect showRect = CGRectMake(
                                 self.contentOffset.x,
                                 self.contentOffset.y,
                                 self.frame.size.width,
                                 self.frame.size.height
                                 );
    
    [self clearCanReuseItemViewForShowRect:showRect];
    [self reuseItemViewForShowRect:showRect];
    
    if (self.isDecelerating) {
        [self scrollViewPageEnd];
    }
}

- (void)dealloc {
    free(self.respondsOfDelegate);
    free(self.respondsOfDataSource);
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    [super setContentOffset:contentOffset animated:animated];
    
    if (!animated) {
        [self scrollViewPageEnd];
    }
}

#pragma mark - Public Method
- (__kindof UIView *)dequeueReusableItemWithIdentifier:(NSString *)identifier {
    NSMutableArray *temp = self.reusePool[identifier];
    
    UIView *itemView = nil;
    if (temp && temp.count > 0) {
        itemView = [temp firstObject];
        [temp removeObject:itemView];
    } else {
        temp = [NSMutableArray new];
        [self.reusePool setObject:temp forKey:identifier];
    }
    return itemView;
}

- (void)reloadData {
    if (self.respondsOfDataSource->numberOfReuseView) {
        self.number = [self.dataSource numberOfReuseView:self];
    }
    
    [self reloadContentSize];
    [self setNeedsLayout];
    if (self.respondsOfDelegate->scrollViewPageEndAtPage) {
        [self.delegate reuseView:self scrollViewPageEndAtPage:self.showPage];
    }
}

- (__kindof UIView *)itemViewAtIndexPath:(NSInteger)indexPath {
    return [self.showPool objectForKey:[NSString stringWithFormat:@"%ld", indexPath]];
}

- (NSInteger)indexPathForItemView:(UIView *)itemView {
    NSInteger indexPath = NSNotFound;
    for (NSString *key in self.showPool.allKeys) {
        if (self.showPool[key] == itemView) {
            return key.integerValue;
        }
    }
    return indexPath;
}

#pragma mark - Private Method
- (void)clearCanReuseItemViewForShowRect:(CGRect)showRect {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![obj isKindOfClass:[UIImageView class]] &&
            !CGRectIntersectsRect(showRect, obj.frame) &&
            !obj.hidden) {
            //回收
            [self recycleItemView:obj];
        }
    }];
}

- (void)reuseItemViewForShowRect:(CGRect)showRect {
    
    CGFloat size = 0.f;
    for (int i = 0; i < self.number; i ++) {
        
        UIView *itemView = nil;
        if (self.respondsOfDataSource->itemViewAtIndexPath) {
            itemView = [self.dataSource reuseView:self itemViewAtIndexPath:i];
        } else {
            itemView = [self dequeueReusableItemWithIdentifier:@"item"];
        }
        
        //该位置上视图的大小
        CGRect itemFrame = CGRectZero;
        CGSize itemSize = CGSizeZero;
        if (self.respondsOfDataSource->itemViewSizeAtIndexPath) {
            itemSize = [self.dataSource reuseView:self itemViewSizeAtIndexPath:i];
        } else {
            itemSize = self.frame.size;
        }
        
        if (itemSize.height == XFReuseViewFixSuperView) {
            itemSize.height = self.frame.size.height;
        }
        
        if (itemSize.width == XFReuseViewFixSuperView) {
            itemSize.width = self.frame.size.width;
        }
        switch (_scrollDirection) {
            case XFReuseViewScrollDirectionVertical: {
                itemFrame = CGRectMake(0.f, size, itemSize.width, itemSize.height);
                size += itemSize.height;
            }
                break;
            case XFReuseViewScrollDirectionHorizontal:{
                itemFrame = CGRectMake(size, 0.f, itemSize.width, itemSize.height);
                size += itemSize.width;
            }
                
                break;
            default:
                break;
        }
        
        //判断这个item的frame是否在可视范围内
        if (!CGRectIntersectsRect(itemFrame, showRect)) {
            continue;
        }
        
        //这个位置在可视范围内， 并且该位置有了item。
        if ([self itemViewAtIndexPath:i]) {
            continue;
        }
        
        if (!itemView.superview) {
            [self addSubview:itemView];
        }
        
        if (self.respondsOfDelegate->itemViewLayoutWithFrame) {
            [self.delegate reuseView:self itemView:itemView layoutWithFrame:itemFrame];
        } else {
            itemView.frame = itemFrame;
        }
        
        [self itemView:itemView enterShowPoolWithIndexPath:i];
    }
}

- (void)recycleItemView:(UIView *)itemView {
    itemView.hidden = YES;
    NSMutableArray* temp = [self.reusePool objectForKey:itemView.identification];
    if (temp == nil) {
        temp = [NSMutableArray new];
        [self.reusePool setObject:temp forKey:itemView.identification];
    }
    [temp addObject:itemView];
    
    for (NSString *key in self.showPool.allKeys) {
        if (self.showPool[key] == itemView) {
            [self.showPool removeObjectForKey:key];
            break;
        }
    }
}

- (void)reloadContentSize {
    CGSize contentSize = CGSizeZero;
    if (self.respondsOfDataSource->itemViewSizeAtIndexPath) {
        for (int i = 0; i < self.number; i ++) {
            
            CGSize size = [self.dataSource reuseView:self itemViewSizeAtIndexPath:i];
            
            if (size.width == XFReuseViewFixSuperView) {
                size.width = self.frame.size.width;
            }
            if (size.height == XFReuseViewFixSuperView) {
                size.height = self.frame.size.height;
            }
            switch (_scrollDirection) {
                case XFReuseViewScrollDirectionVertical:
                    contentSize.height += size.height;
                    break;
                case XFReuseViewScrollDirectionHorizontal:
                    contentSize.width += size.width;
                    break;
                default:
                    break;
            }
        }
    } else {
        switch (_scrollDirection) {
            case XFReuseViewScrollDirectionVertical:
                contentSize.height = self.number * self.frame.size.height;
                break;
            case XFReuseViewScrollDirectionHorizontal:
                contentSize.width = self.number * self.frame.size.width;
                break;
            default:
                break;
        }
    }
    [self setContentSize:contentSize];
}

- (void)itemView:(UIView *)itemView enterShowPoolWithIndexPath:(NSInteger)indexPath {
    if (itemView) {
        itemView.hidden = NO;
        NSString *key = [NSString stringWithFormat:@"%ld", indexPath];
        [self bindTapActionWithItemView:itemView];
        [self.showPool setObject:itemView forKey:key];
    }
}

- (void)bindTapActionWithItemView:(UIView *)itemView {
    
    if (itemView.gestureRecognizers.count == 0) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventOfItemViewTap:)];
        [itemView addGestureRecognizer:tap];
    }
}

- (void)scrollViewPageEnd {
    
    if (self.respondsOfDelegate->scrollViewPageEndAtPage && self.pagingEnabled) {
        NSInteger page = 0;
        
        switch (self.scrollDirection) {
            case XFReuseViewScrollDirectionHorizontal:
                page = (self.contentOffset.x + self.frame.size.width / 2.f) / self.frame.size.width;
                break;
            case XFReuseViewScrollDirectionVertical:
                page = (self.contentOffset.y + self.frame.size.height / 2.f) / self.frame.size.height;
                break;
            default:
                break;
        }
        if (page != self.showPage) {
            
            [self.delegate reuseView:self scrollViewPageEndAtPage:page];
            self.showPage = page;
        }
    }
}

- (void)initialize {
    _reusePool = [[NSMutableDictionary alloc] init];
    _showPool = [NSMutableDictionary new];
    _showPage = 0;
}

#pragma mark - Actions
- (void)eventOfItemViewTap:(UITapGestureRecognizer *)tap {
    UIView *itemView = tap.view;
    
    NSInteger indexPath = [self indexPathForItemView:itemView];
    
    if (indexPath != NSNotFound && self.respondsOfDelegate->didActionAtIndexPath) {
        [self.delegate reuseView:self didActionAtIndexPath:indexPath];
    }
}

#pragma mark - Lazy Load
- (void)setDataSource:(id<XFReuseViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    self.respondsOfDataSource->itemViewAtIndexPath = [dataSource respondsToSelector:@selector(reuseView:itemViewAtIndexPath:)];
    self.respondsOfDataSource->numberOfReuseView = [dataSource respondsToSelector:@selector(numberOfReuseView:)];
    self.respondsOfDataSource->itemViewSizeAtIndexPath = ([dataSource respondsToSelector:@selector(reuseView:itemViewSizeAtIndexPath:)]);
}

- (void)setDelegate:(id<XFReuseViewDelegate>)delegate {
    [super setDelegate:delegate];
    _delegate = delegate;
    
    self.respondsOfDelegate->didActionAtIndexPath = [delegate respondsToSelector:@selector(reuseView:didActionAtIndexPath:)];
    self.respondsOfDelegate->scrollViewPageEndAtPage = [delegate respondsToSelector:@selector(reuseView:scrollViewPageEndAtPage:)];
    self.respondsOfDelegate->itemViewLayoutWithFrame = [delegate respondsToSelector:@selector(reuseView:itemView:layoutWithFrame:)];
}

- (RespondsOfDelegate *)respondsOfDelegate {
    if (_respondsOfDelegate == NULL) {
        _respondsOfDelegate = malloc(sizeof(RespondsOfDelegate));
    }
    return _respondsOfDelegate;
}

- (RespondsOfDataSource *)respondsOfDataSource {
    if (_respondsOfDataSource == NULL) {
        _respondsOfDataSource = malloc(sizeof(RespondsOfDataSource));
    }
    return _respondsOfDataSource;
}

@end
