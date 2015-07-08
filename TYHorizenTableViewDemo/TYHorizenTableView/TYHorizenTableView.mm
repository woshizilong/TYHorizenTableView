//
//  TYHorizenTableView.m
//  TYHorizenTableViewDemo
//
//  Created by tanyang on 15/5/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYHorizenTableView.h"
#import <vector>

typedef struct {
    CGFloat originX;
    CGFloat width;
}TYPosition;

NS_INLINE BOOL TYPositionInPointRange(const TYPosition& position,CGFloat originX, CGFloat endX)
{
    if (position.originX + position.width > originX
        && position.originX < endX){
        return YES;
    }
    return NO;
}

NS_INLINE BOOL TYPointInPosition(CGFloat point,const TYPosition& position)
{
    if (point >= position.originX && point < position.originX + position.width) {
        return YES;
    }
    return NO;
}

// 计算两个range 交集  已经各自的差集
NSRange TYIntersectionRange(NSRange range1, NSRange range2,NSRange& range1Differ,NSRange& range2Differ)
{
    // 计算range
    NSRange interRange = NSIntersectionRange(range1, range2);
    if (interRange.length == 0) {
        // 有交集
        range1Differ = range1;
        range2Differ = range2;
        return interRange;
    }
    
    if (range1.location == range2.location) {
        NSInteger range1MaxRange = NSMaxRange(range1);
        NSInteger range2MaxRange = NSMaxRange(range2);
        if (range1MaxRange < range2MaxRange) {
            range1Differ = NSMakeRange(range1.location, 0);
            range2Differ = NSMakeRange(range1MaxRange, range2MaxRange-range1MaxRange);
        }else {
            range1Differ = NSMakeRange(range2MaxRange,range1MaxRange - range2MaxRange);
            range2Differ = NSMakeRange(range2.location, 0);
        }
        return interRange;
    }
    
    if (range1.location < range2.location) {
        range1Differ = NSMakeRange(range1.location, interRange.location - range1.location);
        range2Differ = NSMakeRange(NSMaxRange(interRange), NSMaxRange(range2) - NSMaxRange(interRange));
    }else {
        range2Differ = NSMakeRange(range2.location, interRange.location - range2.location);
        range1Differ = NSMakeRange(NSMaxRange(interRange), NSMaxRange(range1) - NSMaxRange(interRange));
    }
    return interRange;
}

@interface TYHorizenTableViewCell ()
@property (nonatomic, assign, readwrite) NSInteger index;
@property (nonatomic, copy, readwrite)   NSString  *identifier;
@end

@interface TYHorizenTableView ()<UIScrollViewDelegate>{
    std::vector<TYPosition> _vecCellPositions;  // 所有cell的位置
    NSRange                 _visibleRange;      // 当前可见cell范围
    CGFloat                 _preOffsetX;        // 前一个offset
    
    TYPosition              _leftPostion;       // 左边第一个可见位置
    TYPosition              _rightPositon;      // 右边...
    
    NSInteger               _cellCount;
    
    struct {
        unsigned int didSelectCellAtIndex   :1;
        unsigned int didDeselectCellAtIndex :1;
        unsigned int willDisplayCell        :1;
        unsigned int didEndDisplayingCell   :1;
        unsigned int willSelectCellAtIndex  :1;
    }_delegateFlags;
}

@property (nonatomic, strong) NSMutableDictionary   *visibleCellsDic;   // 显示的cells字典
@property (nonatomic, strong) NSMutableDictionary   *reuseCellsDic;     // 可重用的cell字典
@property (nonatomic, strong) NSMutableDictionary   *reuseIdentifys;    // 注册的class或者nib
@property (nonatomic, assign) NSInteger             selectedIndex;      // 选中的cell
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;        //点击手势

@end

@implementation TYHorizenTableView

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

#pragma mark - setup

- (void)setPropertys
{
    self.backgroundColor = [UIColor whiteColor];
    _visibleCellsDic = [NSMutableDictionary dictionary];
    _reuseCellsDic = [NSMutableDictionary dictionary];
    _vecCellPositions = std::vector<TYPosition>();
    _maxReuseCount = 2;
    _selectedIndex = -1;
    
    [self addSingleTapGesture];
}

- (void)resetPropertys
{
    [[_visibleCellsDic allValues]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_visibleCellsDic removeAllObjects];

    for (NSSet *set in [_reuseCellsDic allValues]) {
        [set makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [_reuseCellsDic removeAllObjects];
    _visibleRange = NSMakeRange(0, 0);
    _selectedIndex = -1;
    
    _vecCellPositions.clear();
}

- (void)setDelegate:(id<TYHorizenTableViewDelegate>)delegate
{
    [super setDelegate:delegate];
    
    _delegateFlags.didSelectCellAtIndex = [delegate respondsToSelector:@selector(horizenTableView:didSelectCellAtIndex:)];
    _delegateFlags.willDisplayCell = [delegate respondsToSelector:@selector(horizenTableView:willDisplayCell:atIndex:)];
    _delegateFlags.didEndDisplayingCell = [delegate respondsToSelector:@selector(horizenTableView:didEndDisplayingCell:atIndex:)];
    
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

- (NSMutableDictionary *)reuseIdentifys
{
    if (_reuseIdentifys == nil) {
        _reuseIdentifys = [NSMutableDictionary dictionary];
    }
    return _reuseIdentifys;
}

#pragma mark - public method

// reload Data
- (void)reloadData
{
    // 重置属性
    [self resetPropertys];
    
    // 计算所有cell的位置
    [self calculateCellPositions];
    
    // 布局所有可见cell frame
    [self updateVisibleCells];
}

- (void)reloadItemAtIndex:(NSInteger)index
{
    TYHorizenTableViewCell *cell = _visibleCellsDic[@(index)];
    if (cell) {
        [self enqueueUnuseCell:cell];
    }
    cell = [_dataSource horizenTableView:self cellForItemAtIndex:index];
    
    // 添加cell到index位置
    [self addCell:cell atIndex:index];
}

- (void)reloadItemAtIndexSet:(NSIndexSet *)indexSet
{
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self reloadItemAtIndex:idx];
    }];
}

// reuse cell with identifier
- (TYHorizenTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    NSMutableSet *set = [_reuseCellsDic objectForKey:identifier];
    if (set && set.count > 0) {
        TYHorizenTableViewCell *reuseCell = [set anyObject];
        if (reuseCell) {
            [set removeObject:reuseCell];
        }
        return reuseCell;
    }
    
    if (set == nil) {
        set = [NSMutableSet setWithCapacity:_maxReuseCount];
        _reuseCellsDic[identifier] = set;
    }
    
    id registerId = nil;
    if (_reuseIdentifys && (registerId = [_reuseIdentifys objectForKey:identifier])) {
        if ([registerId isKindOfClass:[UINib class]]) {
            return [TYHorizenTableViewCell cellWithNib:registerId identifier:identifier];
        }else {
            return [[registerId alloc]initWithReuseIdentifier:identifier];
        }
    }
    return nil;
}

- (TYHorizenTableViewCell *)cellForIndex:(NSInteger)index
{
    return [_visibleCellsDic objectForKey:@(index)];
}

- (NSArray *)visibleCells
{
    return [_visibleCellsDic allValues];
}

// reigister cell
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    self.reuseIdentifys[identifier] = cellClass;
}

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier
{
    self.reuseIdentifys[identifier] = nib;
}

// scroll
- (void)scrollToIndex:(NSInteger)index atPosition:(TYHorizenTableViewPosition)position animated:(BOOL)animated
{
    if ((index < 0 || index >= _vecCellPositions.size()) && _itemWidth <= 0) {
        return;
    }
    TYPosition cellVisiblePositon = [self TYPositonWithIndex:index];
    
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    switch (position) {
        
        case TYHorizenTableViewPositionNone:
        case TYHorizenTableViewPositionLeft:
            break;
            
        case TYHorizenTableViewPositionRight:
            cellVisiblePositon.originX += cellVisiblePositon.width - viewWidth;
            break;
            
        case TYHorizenTableViewPositionCenter:
            cellVisiblePositon.originX -= (viewWidth - cellVisiblePositon.width)/2;
            break;
            
        default:
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

// select and deselect cell
- (void)deSelectCellAtIndex:(NSInteger)index animated:(BOOL)animated
{
    TYHorizenTableViewCell *unSelectCell = [self cellForIndex:index];
    if (unSelectCell) {
        [unSelectCell setSelected:NO animated:animated];
    }
    
    if (_selectedIndex == index) {
        _selectedIndex = -1;
    }
}

- (void)selectCellAtIndex:(NSInteger)index animated:(BOOL)animated
{
    TYHorizenTableViewCell *cell = [self cellForIndex:index];
    if (cell) {
        [cell setSelected:YES animated:animated];
    }
    _selectedIndex = index;
}

- (void)selectCellAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(TYHorizenTableViewPosition)position
{
    [self deSelectCellAtIndex:_selectedIndex animated:animated];
    [self selectCellAtIndex:index animated:animated];
    [self scrollToIndex:index atPosition:position animated:animated];
}

#pragma mark - private method

- (TYPosition)TYPositonWithIndex:(NSInteger)index
{
    if (_itemWidth > 0) {
        return {index * (_itemWidth+_itemSpacing)+_edgeInsets.left,_itemWidth};
    }
    return _vecCellPositions[index];
}

// 计算所有cell的位置
- (void)calculateCellPositions
{
    if (_itemWidth > 0) {
        [self caculateEqualCellPositons];
    }else {
        [self calculateUnequalCellPositions];
    }
}

- (void)caculateEqualCellPositons
{
    // 获得item的数目
    NSInteger numberOfItems = [_dataSource horizenTableViewOnNumberOfItems:self];
    _cellCount = numberOfItems;
    CGFloat contentWidth  = _edgeInsets.left + numberOfItems * (_itemWidth + _itemSpacing) - _itemSpacing +_edgeInsets.right;
    CGFloat contentHeight = CGRectGetHeight(self.frame);
    
    self.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)calculateUnequalCellPositions
{
    // 获得item的数目
    NSInteger numberOfItems = [_dataSource horizenTableViewOnNumberOfItems:self];
    _cellCount = numberOfItems;
    CGFloat contentWidth  = _edgeInsets.left;
    CGFloat contentHeight = CGRectGetHeight(self.frame);
    
    if (_vecCellPositions.size() == 0) {
        _vecCellPositions.reserve(numberOfItems);
    }
    
    // 计算所有cell的frame
    for (int index = 0; index < numberOfItems; ++index) {
        CGFloat itemWidth = [_dataSource horizenTableView:self widthForItemAtIndex:index];
        TYPosition cellPosition = {contentWidth,itemWidth};
        _vecCellPositions.push_back(cellPosition);
        
        NSInteger cellSpace = (index == numberOfItems-1) ? _edgeInsets.right : _itemSpacing;
        contentWidth += itemWidth + cellSpace;
    }
    
    self.contentSize = CGSizeMake(contentWidth, contentHeight);
}

// 更新可见cells
- (void)updateVisibleCells
{
    CGFloat offsetLeftX = self.contentOffset.x;
    CGFloat offsetRightX = offsetLeftX + CGRectGetWidth(self.frame);
    
    // 优化性能
    if (TYPointInPosition(offsetLeftX, _leftPostion)
        && TYPointInPosition(offsetRightX, _rightPositon) ) {
        _preOffsetX = offsetLeftX;
        return;
    }
    
    // 获取可见range
    NSRange visibleCellRange = [self getVisibleCellRangWithVisibleOrignX:offsetLeftX visibleEndX:offsetRightX];
    
    // 优化性能
    if (NSEqualRanges(_visibleRange, visibleCellRange)) {
        return;
    }
    
    NSRange preVisibleCellRange = _visibleRange;
    _visibleRange = visibleCellRange;
    
    _leftPostion = [self TYPositonWithIndex:visibleCellRange.location];
    _rightPositon = [self TYPositonWithIndex:NSMaxRange(visibleCellRange)-1];
    
    [self layoutCellWithVisibleRange:visibleCellRange preVisibleRange:preVisibleCellRange];

    //[self printVisibleAndReuseCellCount];
}

// 获取可见cells的range
- (NSRange)getVisibleCellRangWithVisibleOrignX:(CGFloat)visibleOrignX visibleEndX:(CGFloat)visibleEndX
{
    if (_itemWidth > 0) {
        return [self getVisibleEqualCellRangWithVisibleOrignX:visibleOrignX visibleEndX:visibleEndX];
    }
    return [self getVisibleUnequalCellRangeWithVisibleOrignX:visibleOrignX visibleEndX:visibleEndX];
}

- (NSRange)getVisibleEqualCellRangWithVisibleOrignX:(CGFloat)visibleOrignX visibleEndX:(CGFloat)visibleEndX
{
    NSInteger startIndex = (visibleOrignX - _edgeInsets.left + _itemSpacing)/(_itemWidth + _itemSpacing);
        
    NSInteger endIndex = ceil((visibleEndX - _edgeInsets.left)/(_itemWidth + _itemSpacing));
    _preOffsetX = visibleOrignX;
    if (startIndex < 0) {
        startIndex = 0;
    }
    if (endIndex > _cellCount) {
        endIndex = _cellCount;
    }
    return NSMakeRange(startIndex, endIndex - startIndex);
}

- (NSRange)getVisibleUnequalCellRangeWithVisibleOrignX:(CGFloat)visibleOrignX visibleEndX:(CGFloat)visibleEndX
{
    
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
    
    BOOL isOverVisibleRect = NO; // 优化次数
    NSInteger startIndex = 0, endIndex = 0;
    NSInteger count = _vecCellPositions.size();
    
    for (;index < count; ++index) {
        if (TYPositionInPointRange(_vecCellPositions.at(index), visibleOrignX, visibleEndX)) {
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

// 计算range 交集与差集,然后布局
- (void)layoutCellWithVisibleRange:(NSRange)visibleCellRange preVisibleRange:(NSRange)preVisibleRange
{
     NSRange willDisapperRange, willDisplayRange;
    
    TYIntersectionRange(preVisibleRange, visibleCellRange, willDisapperRange, willDisplayRange);
    
    // 先回收
    for (NSInteger index = willDisapperRange.location; index < NSMaxRange(willDisapperRange); ++index) {
        TYHorizenTableViewCell *cell = [_visibleCellsDic objectForKey:@(index)];
        if (cell) {
            [self enqueueUnuseCell:cell];
            
            [_visibleCellsDic removeObjectForKey:@(index)];
        }
    }
    
    // 后重用
    for (NSInteger index = willDisplayRange.location; index < NSMaxRange(willDisplayRange); ++index) {
        TYHorizenTableViewCell *cell = [_visibleCellsDic objectForKey:@(index)];
        if (!cell) {
            cell = [_dataSource horizenTableView:self cellForItemAtIndex:index];
            // 添加cell到index位置
            [self addCell:cell atIndex:index];
        }
        
        if (_selectedIndex == index) {
            [cell setSelected:YES animated:NO];
        }else if (cell.selected){
            [cell setSelected:NO animated:NO];
        }
    }
}

// 添加cell
- (void)addCell:(TYHorizenTableViewCell *)cell atIndex:(NSInteger)index
{
    cell.index = index;
    TYPosition cellPosition = [self TYPositonWithIndex:index];
    [cell setFrame:CGRectMake(cellPosition.originX, _edgeInsets.top, cellPosition.width, CGRectGetHeight(self.frame)-_edgeInsets.top-_edgeInsets.bottom)];
    
    if (cell.superview == nil) {
        [self addSubview:cell];
    }else if (cell.superview != self){
        [cell removeFromSuperview];
        [self addSubview:cell];
    }else if (cell.hidden) {
        cell.hidden = NO;
    }
    _visibleCellsDic[@(index)] = cell;
    
    if (_delegateFlags.willDisplayCell) {
        [self.delegate horizenTableView:self willDisplayCell:cell atIndex:index];
    }
}

// 回收缓存cells
- (void)enqueueUnuseCell:(TYHorizenTableViewCell*)cell
{
    if (_delegateFlags.willDisplayCell) {
        [self.delegate horizenTableView:self willDisplayCell:cell atIndex:cell.index];
    }
    
    NSMutableSet *set = [_reuseCellsDic objectForKey:cell.identifier];
    if (set == nil) {
        set = [NSMutableSet setWithCapacity:_maxReuseCount];
        _reuseCellsDic[cell.identifier] = set;
    }
    if (set.count < _maxReuseCount){
        cell.index = -1;
        cell.hidden = YES;
        [cell didDequeUnuseCell];
        [set addObject:cell];
    }else {
        [cell removeFromSuperview];
    }
}

#pragma mark - action Handle
// 点击事件
- (void)singleTapGesture:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    NSArray *visibleCells = [_visibleCellsDic allValues];
    NSInteger index = -1;
    for (TYHorizenTableViewCell *cell in visibleCells) {
        if (CGRectContainsPoint(cell.frame, point)) {
            index = cell.index;
            break;
        }
    }
    
    if (index >= 0) {
        [self handleEventSelectCellAtIndex:index];
    }
}

- (void)handleEventSelectCellAtIndex:(NSInteger)index
{
    if (_delegateFlags.willSelectCellAtIndex) {
        index = [self.delegate horizenTableView:self willSelectCellAtIndex:index];
        //NSLog(@"change select cell index :%ld",(long)index);
    }
    
    if (index != _selectedIndex) {
        [self deSelectCellAtIndex:_selectedIndex animated:YES];
        if (_delegateFlags.didDeselectCellAtIndex) {
            [self.delegate horizenTableView:self willSelectCellAtIndex:index];
        }
    }
    
    [self selectCellAtIndex:index animated:YES];
    if (_delegateFlags.didSelectCellAtIndex) {
        [self.delegate horizenTableView:self didSelectCellAtIndex:index];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateVisibleCells];
}

- (void)printVisibleAndReuseCellCount
{
    NSMutableSet *set = _reuseCellsDic[_reuseIdentifys.allKeys.firstObject];
    NSLog(@"visible cell num:%d",(int)_visibleCellsDic.count);
    NSLog(@"reuse cell num:%d",(int)set.count);
}

- (void)dealloc
{
    _vecCellPositions.clear();
}

@end
