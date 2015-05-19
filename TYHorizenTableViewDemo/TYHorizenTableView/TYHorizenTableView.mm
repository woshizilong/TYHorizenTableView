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

typedef struct {
    CGFloat originX;
    CGFloat width;
}TYPosition;

@interface TYHorizenTableView ()<UIScrollViewDelegate>{
    std::vector<TYPosition> _vecCellPositions;  // 所有cell的位置
    NSRange             _visibleRange;          // 当前可见cell范围
    CGFloat             _preOffsetX;            // 前一个offset
}

@property (nonatomic, strong) NSMutableDictionary   *visibleCells; // 显示的cells字典
@property (nonatomic, strong) NSMutableDictionary   *reuseCells;   // 可重用的cell字典
@property (nonatomic, assign) NSInteger             selectedIndex; // 选中的cell
@property (nonatomic, strong) UITapGestureRecognizer* singleTap;   //点击手势
@property (nonatomic, strong) NSMutableArray *unVisibelCellKeys;

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
    _unVisibelCellKeys = [NSMutableArray array];
    _vecCellPositions = std::vector<TYPosition>();
    _maxReuseCount = 2;
    _selectedIndex = -1;
    
    [self addSingleTapGesture];
}

- (void)resetPropertys
{
    [[_visibleCells allValues]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_visibleCells removeAllObjects];
    [[_reuseCells allValues]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reuseCells removeAllObjects];
    [_unVisibelCellKeys removeAllObjects];
    _visibleRange = NSMakeRange(0, 0);
    _selectedIndex = -1;
    
    _vecCellPositions.clear();
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
    if (index < 0 || index >= _vecCellPositions.size()) {
        return;
    }
    TYPosition cellVisiblePositon = _vecCellPositions[index];
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    
    switch (position) {
            
        case TYHorizenTableViewPositionLeft:
            break;
            
        case TYHorizenTableViewPositionRight:
            cellVisiblePositon.originX += cellVisiblePositon.width - viewWidth;
            break;
            
        case TYHorizenTableViewPositionCenter:
            cellVisiblePositon.originX -= (viewWidth - cellVisiblePositon.width)/2;
            break;
            
        default:
        case TYHorizenTableViewPositionNone:
            break;
    }
    
    if (cellVisiblePositon.originX < 0.0) {
        cellVisiblePositon.originX = 0.0;
    }else if (cellVisiblePositon.originX > self.contentSize.width - viewWidth) {
        cellVisiblePositon.originX = self.contentSize.width - viewWidth;
    }
    
    CGRect cellVisibleFrame  = CGRectMake(cellVisiblePositon.originX, 0, viewWidth, CGRectGetHeight(self.frame));
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
    CGFloat contentWidth  = _edgeInsets.left;
    CGFloat contentHeight = CGRectGetHeight(self.frame);
    
    _vecCellPositions.reserve(numberOfItems);
    
    // 计算所有cell的frame
    for (int index = 0; index < numberOfItems; ++index) {
        CGFloat cellWidth = [_dataSource horizenTableView:self widthForItemAtIndex:index];
        TYPosition cellPosition = {contentWidth,cellWidth};
        _vecCellPositions.push_back(cellPosition);
        
        NSInteger cellSpace = (index == numberOfItems-1) ? _edgeInsets.right : _cellSpacing;
        contentWidth += cellWidth + cellSpace;
    }
    
    self.contentSize = CGSizeMake(contentWidth, contentHeight);
}

// 布局可见cells
- (void)layoutVisibleCells
{
    
    NSRange visibleCellRange = [self getVisibleCellRange];
    
    // 优化性能
    if (NSEqualRanges(_visibleRange, visibleCellRange)) {
        return;
    }
    _visibleRange = visibleCellRange;

    [_unVisibelCellKeys addObjectsFromArray:[_visibleCells allKeys]];
    for (NSInteger index = visibleCellRange.location; index < NSMaxRange(visibleCellRange); ++index) {
        
        TYHorizenTableViewCell *cell = [_visibleCells objectForKey:@(index)];
        if (!cell) {
            cell = [_dataSource horizenTableView:self cellForItemAtIndex:index];
            // 添加cell到index位置
            [self addCell:cell atIndex:index];
        }else{
            [_unVisibelCellKeys removeObject:@(index)];
        }
        
        if (_selectedIndex == index) {
            [cell setSelected:YES animated:NO];
        }else if (cell.selected){
            [cell setSelected:NO animated:NO];
        }
        
    }
    
    // 把多余不显示的加入重用池
    for (NSNumber *index in _unVisibelCellKeys) {
        TYHorizenTableViewCell *cell = [_visibleCells objectForKey:index];
        if (cell) {
            [self enqueueUnuseCell:cell];
        }
    }
    
    [_visibleCells removeObjectsForKeys:_unVisibelCellKeys];
    [_unVisibelCellKeys removeAllObjects];
    
}

// 获取可见cells的rang
- (NSRange)getVisibleCellRange
{
    BOOL isOverVisibleRect = NO; // 优化次数
    // 可见区域rect
    CGFloat visibleOrignX = self.contentOffset.x;
    CGFloat visibleEndX = visibleOrignX + CGRectGetWidth(self.frame);
    
    NSInteger index = 0;
    if (visibleOrignX > _preOffsetX) {
        index = _visibleRange.location;
    } else if (_preOffsetX - visibleOrignX < 5.0){
        index = _visibleRange.location - 1;
    }
    
    if (index < 0) {
        index = 0;
    }
    _preOffsetX = visibleOrignX;
    
    NSInteger startIndex = 0, endIndex = 0;
    NSInteger count = _vecCellPositions.size();
    
    for (;index < count; ++index) {
        const TYPosition& cellPosition = _vecCellPositions[index];
        if (cellPosition.originX + cellPosition.width >= visibleOrignX
            && cellPosition.originX < visibleEndX) {
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

// 添加cell
- (void)addCell:(TYHorizenTableViewCell *)cell atIndex:(NSInteger)index
{
    cell.index = index;
    const TYPosition& cellPosition = _vecCellPositions[index];
    CGRect cellFrame = CGRectMake(cellPosition.originX, _edgeInsets.top, cellPosition.width, CGRectGetHeight(self.frame)-_edgeInsets.top-_edgeInsets.bottom);
    
    [cell setFrame:cellFrame];
    if (cell.superview != self) {
        [cell removeFromSuperview];
        [self addSubview:cell];
    }else if (cell.hidden) {
        cell.hidden = NO;
    }
    
    _visibleCells[@(index)] = cell;
}

// 缓存cells
- (void)enqueueUnuseCell:(TYHorizenTableViewCell*)cell
{
    NSMutableSet *set = [_reuseCells objectForKey:cell.identifier];
    if (set == nil) {
        set = [NSMutableSet setWithCapacity:_maxReuseCount];
        _reuseCells[cell.identifier] = set;
    }
    if (set.count < _maxReuseCount){
        cell.index = -1;
        cell.hidden = YES;
        [set addObject:cell];
    }else {
        [cell removeFromSuperview];
    }
}

- (TYHorizenTableViewCell *)cellForIndex:(NSInteger)index
{
    return [_visibleCells objectForKey:@(index)];
}

// 点击事件
- (void)singleTapGesture:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    NSArray *visibleCells = [_visibleCells allValues];
    
    for (TYHorizenTableViewCell *cell in visibleCells) {
        if (CGRectContainsPoint(cell.frame, point) && !cell.hidden) {
            NSLog(@"select cell index :%ld",(long)cell.index);
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
