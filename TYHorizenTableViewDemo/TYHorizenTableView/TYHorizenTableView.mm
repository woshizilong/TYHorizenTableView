//
//  TYHorizenTableView.m
//  TYHorizenTableViewDemo
//
//  Created by SunYong on 15/5/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYHorizenTableView.h"
#import <vector>

@interface TYHorizenTableViewCell ()
@property (nonatomic, assign, readwrite) NSInteger   index;
@property (nonatomic, assign, readwrite) BOOL       selected;
@end

@interface TYHorizenTableView ()<UIScrollViewDelegate>{
    std::vector<CGRect>             _vecCellFrames;         // 所有cell的frames
}

@property (nonatomic, strong) NSMutableDictionary   *visibleCells;  // 显示的cells字典
@property (nonatomic, strong) NSMutableDictionary   *reuseCells;    // 可重用的cell字典
@property (nonatomic, assign) NSInteger             selectedIndex;  // 选中的cell

@property (nonatomic, strong) UITapGestureRecognizer* singleTap; //点击手势

@end

@implementation TYHorizenTableView

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setPropertys];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setPropertys];
    }
    return self;
}

- (void)setPropertys
{
    _visibleCells = [NSMutableDictionary dictionary];
    _reuseCells = [NSMutableDictionary dictionary];
    _vecCellFrames = std::vector<CGRect>();
    _selectedIndex = -1;
    
    [self addSingleTapGesture];
}

- (void)resetPropertys
{
    [_visibleCells removeAllObjects];
    [_reuseCells removeAllObjects];
    _selectedIndex = -1;
    
    _vecCellFrames.clear();
}

- (void)setDelegate:(id<TYHorizenTableViewDelegate>)delegate
{
    [super setDelegate:delegate];
}

- (void)reloadData
{
    // 重置属性
    [self resetPropertys];
    
    // 计算所有cell的frame
    [self calculateCellFrames];
    
    // 布局所有可见cell frame
    [self layoutVisibleCells];
}

- (void)addSingleTapGesture
{
    if (_singleTap == nil) {
        self.userInteractionEnabled = YES;
        //单指单击
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
        //手指数
        _singleTap.numberOfTouchesRequired = 1;
        //点击次数
        _singleTap.numberOfTapsRequired = 1;
        //增加事件者响应者，
        [self addGestureRecognizer:_singleTap];
    }
}

#pragma mark - public method

- (TYHorizenTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if ([[self.reuseCells allKeys]containsObject:identifier]) {
        NSMutableSet *set = self.reuseCells[identifier];
        TYHorizenTableViewCell *reuseCell = [set anyObject];
        
        if (reuseCell) {
            [set removeObject:reuseCell];
        }
        return reuseCell;
    }
    return nil;
}

- (void)selectCellAtIndex:(NSInteger)index animated:(BOOL)animated
{
    TYHorizenTableViewCell *cell = [self cellForIndex:index];
    [self selectCell:cell animated:animated];
}

#pragma mark - private method

- (void)calculateCellFrames
{
    // 获得item的数目
    NSInteger numberOfItems = [_dataSource horizenTableViewOnNumberOfItems:self];
    CGFloat contentWidth  = 0;
    CGFloat contentHeight = CGRectGetHeight(self.frame);
    
    _vecCellFrames.reserve(numberOfItems);
    
    // 计算所有cell的frame
    for (int index = 0; index < numberOfItems; ++index) {
        CGFloat cellWidth = [_dataSource horizenTableView:self widthForItemAtIndex:index];
        CGRect cellFrame = CGRectMake(contentWidth, 0, cellWidth, contentHeight);
        
        contentWidth += cellWidth + ((index > 1 || index < numberOfItems) ? _cellSpacing : 0);
        _vecCellFrames.push_back(cellFrame);
    }
    
    self.contentSize = CGSizeMake(contentWidth, 0);
}

- (void)layoutVisibleCells
{
    NSRange visibleCellRange = [self getVisibleCellRange];
    NSMutableDictionary *noVisibleCells = [_visibleCells mutableCopy];
    
    for (NSInteger index = visibleCellRange.location; index < NSMaxRange(visibleCellRange); ++index) {
        
        TYHorizenTableViewCell *cell = [_visibleCells objectForKey:@(index)];
        if (!cell) {
            cell = [_dataSource horizenTableView:self cellForItemAtIndex:index];
            // 添加cell到index位置
            [self addCell:cell atIndex:index];
        }else{
            [noVisibleCells removeObjectForKey:@(index)];
        }
        
        [cell setSelected:(_selectedIndex == index) animated:NO];
        
    }
    
    // 把多余不显示的加入重用池
    [noVisibleCells enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, id obj, BOOL *stop) {
        [self enqueueCell:obj atIndex:[index integerValue]];
    }];
        
}


- (void)enqueueCell:(TYHorizenTableViewCell*)cell atIndex:(NSInteger)index
{
    NSString *identifier = cell.identifier;
    NSMutableSet *set = [_reuseCells objectForKey:identifier];
    if (set == nil) {
        set = [NSMutableSet set];
        [_reuseCells setObject:set forKey:identifier];
    }
    if (set.count < 2){
        cell.index = -1;
        [set addObject:cell];
    }
    
    [cell removeFromSuperview];
    [_visibleCells removeObjectForKey:@(index)];
}

- (void)addCell:(TYHorizenTableViewCell *)cell atIndex:(NSInteger)index
{
    cell.index = index;
    CGRect cellFrame = _vecCellFrames[index];
    [cell setFrame:cellFrame];
    if (cell.superview) {
        [cell removeFromSuperview];
    }
    [self addSubview:cell];
    
    [_visibleCells setObject:cell forKey:@(index)];
}

- (TYHorizenTableViewCell *)cellForIndex:(NSInteger)index
{
    return [_visibleCells objectForKey:@(index)];
}

- (NSRange)getVisibleCellRange
{
    BOOL isOverVisibleRect = NO; // 优化次数
    // 可见区域rect
    CGRect visibleRect = CGRectMake(self.contentOffset.x, self.contentOffset.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    NSInteger startIndex = 0, endIndex = 0;
    NSInteger index = 0, count = _vecCellFrames.size();
    
    for (; index < count; ++index) {
        CGRect cellRect = _vecCellFrames[index];
        if (CGRectIntersectsRect(visibleRect,cellRect)) {
            // 在可见区域
            if (!isOverVisibleRect) {
                startIndex = index;
                isOverVisibleRect = YES;
            }
        }else if (isOverVisibleRect){
            endIndex = index;
            break;
        }
    }
    
    if (endIndex == 0) {
        endIndex = index;
    }
    
    return NSMakeRange(startIndex, endIndex - startIndex);
}

- (void)singleTapGesture:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    NSArray *visibleCells = [_visibleCells allValues];
    
    for (TYHorizenTableViewCell *cell in visibleCells) {
        if (CGRectContainsPoint(cell.frame, point)) {
            NSLog(@"select cell index :%ld",cell.index);
            if ([self.delegate respondsToSelector:@selector(horizenTableView:didSelectCellAtIndex:)]) {
                [self.delegate horizenTableView:self didSelectCellAtIndex:cell.index];
            }
            [self selectCell:cell animated:YES];
            break;
        }
    }
}

- (void)selectCell:(TYHorizenTableViewCell *)cell animated:(BOOL)animated
{
    if (_selectedIndex != cell.index) {
        [cell setSelected:YES animated:animated];
        TYHorizenTableViewCell *unSelectCell = [_visibleCells objectForKey:@(_selectedIndex)];
        if (unSelectCell) {
            [unSelectCell setSelected:NO animated:animated];
        }
        _selectedIndex = cell.index;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutVisibleCells];
    
//    NSMutableSet *set = _reuseCells[@"cell"];
//    NSLog(@"visible cell num:%ld",_visibleCells.count);
//    NSLog(@"reuse cell num:%ld",set.count);
}

- (void)dealloc
{
    [self resetPropertys];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
