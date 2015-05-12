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
@end

@interface TYHorizenTableView ()<UIScrollViewDelegate>{
    std::vector<CGRect> _vecCellFrames;         // 所有cell的frames
    NSRange             _visibleRange;
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
    self.backgroundColor = [UIColor whiteColor];
    _visibleCells = [NSMutableDictionary dictionary];
    _reuseCells = [NSMutableDictionary dictionary];
    _vecCellFrames = std::vector<CGRect>();
    _selectedIndex = -1;
    
    [self addSingleTapGesture];
}

- (void)resetPropertys
{
    [[_visibleCells allValues]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_visibleCells removeAllObjects];
    [[_reuseCells allValues]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reuseCells removeAllObjects];
    _visibleRange = NSMakeRange(0, 0);
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
    NSMutableSet *set = [_reuseCells objectForKey:identifier];
    if (set && set.count > 0) {
        TYHorizenTableViewCell *reuseCell = [set anyObject];
        if (reuseCell) {
            [set removeObject:reuseCell];
        }
        return reuseCell;
    }
    return nil;
}

- (void)scrollToIndex:(NSInteger)index atPosition:(TYHorizenTableViewPosition)position animated:(BOOL)animated
{
    if (index < 0 || index >= _vecCellFrames.size()) {
        return;
    }
    CGRect cellVisibleFrame = _vecCellFrames[index];
    
    switch (position) {
            
        case TYHorizenTableViewPositionLeft:
            break;
            
        case TYHorizenTableViewPositionRight:
            cellVisibleFrame.origin.x += CGRectGetWidth(cellVisibleFrame) - CGRectGetWidth(self.frame);
            break;
            
        case TYHorizenTableViewPositionCenter:
            cellVisibleFrame.origin.x -= (CGRectGetWidth(self.frame) - CGRectGetWidth(cellVisibleFrame))/2;
            break;
            
        default:
        case TYHorizenTableViewPositionNone:
            break;
    }
    
    if (cellVisibleFrame.origin.x < 0.0) {
        cellVisibleFrame.origin.x = 0.0;
    }else if (cellVisibleFrame.origin.x > self.contentSize.width - CGRectGetWidth(self.frame)) {
        cellVisibleFrame.origin.x = self.contentSize.width - CGRectGetWidth(self.frame);
    }
    
    cellVisibleFrame.size = self.frame.size;
    [self scrollRectToVisible:cellVisibleFrame animated:animated];
    //[self setContentOffset:cellVisibleFrame.origin animated:animated];
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
        NSInteger cellSpace = (index == numberOfItems-1) ? 0 : _cellSpacing;
        contentWidth += cellWidth + cellSpace;
        _vecCellFrames.push_back(cellFrame);
    }
    
    self.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)layoutVisibleCells
{
    NSRange visibleCellRange = [self getVisibleCellRange];
    
    // 优化性能
    if (NSEqualRanges(_visibleRange, visibleCellRange)) {
        return;
    }

    NSMutableArray *unVisibelCellKeys = [NSMutableArray arrayWithArray:[_visibleCells allKeys]];
    for (NSInteger index = visibleCellRange.location; index < NSMaxRange(visibleCellRange); ++index) {
        
        TYHorizenTableViewCell *cell = [_visibleCells objectForKey:@(index)];
        if (!cell) {
            cell = [_dataSource horizenTableView:self cellForItemAtIndex:index];
            // 添加cell到index位置
            [self addCell:cell atIndex:index];
        }else{
            [unVisibelCellKeys removeObject:@(index)];
        }
        
        if (_selectedIndex == index) {
            [cell setSelected:YES animated:NO];
        }else if (cell.selected){
            [cell setSelected:NO animated:NO];
        }
        
    }
    
    // 把多余不显示的加入重用池
    for (NSNumber *index in unVisibelCellKeys) {
        TYHorizenTableViewCell *cell = [_visibleCells objectForKey:index];
        if (cell) {
            [self enqueueCell:cell atIndex:index];
        }
    }
    
}


- (void)enqueueCell:(TYHorizenTableViewCell*)cell atIndex:(NSNumber *)index
{
    NSMutableSet *set = [_reuseCells objectForKey:cell.identifier];
    if (set == nil) {
        set = [NSMutableSet set];
        _reuseCells[cell.identifier] = set;
    }
    if (set.count < 2){
        cell.index = -1;
        cell.hidden = YES;
        [set addObject:cell];
    }else {
        [cell removeFromSuperview];
    }
    
    [_visibleCells removeObjectForKey:index];
}

- (void)addCell:(TYHorizenTableViewCell *)cell atIndex:(NSInteger)index
{
    cell.index = index;
    CGRect cellFrame = _vecCellFrames[index];
    [cell setFrame:cellFrame];
    if (cell.superview != self) {
        [cell removeFromSuperview];
        [self addSubview:cell];
    }else {
        cell.hidden = NO;
    }

    _visibleCells[@(index)] = cell;
}

- (TYHorizenTableViewCell *)cellForIndex:(NSInteger)index
{
    return [_visibleCells objectForKey:@(index)];
}

- (NSRange)getVisibleCellRange
{
    BOOL isOverVisibleRect = NO; // 优化次数
    // 可见区域rect
    CGRect visibleRect = {self.contentOffset,self.frame.size};
    //CGRectMake(self.contentOffset.x, self.contentOffset.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    NSInteger startIndex = 0, endIndex = 0;
    NSInteger index = _visibleRange.location > 0 ? _visibleRange.location - 1:0;
    NSInteger count = _vecCellFrames.size();
    
    for (; index < count; ++index) {
        //CGRect cellRect = _vecCellFrames[index];
        if (CGRectIntersectsRect(visibleRect,_vecCellFrames[index])) {
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
    //[super layoutSubviews];
    [self layoutVisibleCells];

    
//    NSMutableSet *set = _reuseCells[@"cell"];
//    NSLog(@"visible cell num:%ld",_visibleCells.count);
//    NSLog(@"reuse cell num:%ld",set.count);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc
{
    [self resetPropertys];
}

@end
