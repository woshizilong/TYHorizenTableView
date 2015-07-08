//
//  TYHorizenTableView.h
//  TYHorizenTableViewDemo
//
//  Created by tanyang on 15/5/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//  Horizen Scroll TableView

#import <UIKit/UIKit.h>
#import "TYHorizenTableViewCell.h"

typedef enum {
    TYHorizenTableViewPositionNone = 0, // 不滚动
    TYHorizenTableViewPositionLeft,     // 滚动到左边
    TYHorizenTableViewPositionRight,    //
    TYHorizenTableViewPositionCenter,   // 
} TYHorizenTableViewPosition;

@class TYHorizenTableView;

@protocol TYHorizenTableViewDataSource <NSObject>
@required

// Total number of items
- (NSInteger)horizenTableViewOnNumberOfItems:(TYHorizenTableView *)horizenTableView;

//Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier
// get cell for display
- (TYHorizenTableViewCell *)horizenTableView:(TYHorizenTableView *)horizenTableView cellForItemAtIndex:(NSInteger)index;

@optional

// Variable width support ,if width is equal ,you can use itemWidth
- (CGFloat)horizenTableView:(TYHorizenTableView *)horizenTableView widthForItemAtIndex:(NSInteger)index;

@end

@protocol TYHorizenTableViewDelegate <UIScrollViewDelegate>
@optional

// Called before the user changes the selection. Return a new index, or 0, to change the proposed selection.
- (NSInteger)horizenTableView:(TYHorizenTableView *)horizenTableView willSelectCellAtIndex:(NSInteger)index;

// Called after the user changes the selection.点击cell
- (void)horizenTableView:(TYHorizenTableView *)horizenTableView didSelectCellAtIndex:(NSInteger)index;
- (void)horizenTableView:(TYHorizenTableView *)horizenTableView didDeselectCellAtIndex:(NSInteger)index;

// cell will Display
- (void)horizenTableView:(TYHorizenTableView *)horizenTableView willDisplayCell:(TYHorizenTableViewCell *)cell atIndex:(NSInteger)index;
// cell did Disappear
- (void)horizenTableView:(TYHorizenTableView *)horizenTableView didEndDisplayingCell:(TYHorizenTableViewCell *)cell atIndex:(NSInteger)index;

@end

@interface TYHorizenTableView : UIScrollView

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-property-synthesis"
@property (nonatomic, assign) id<TYHorizenTableViewDataSource>  dataSource;
@property (nonatomic, assign) id<TYHorizenTableViewDelegate>    delegate;
#pragma clang diagnostic pop
@property (nonatomic, assign) CGFloat           itemWidth;    // item的宽度 会相应优化
@property (nonatomic, assign) CGFloat           itemSpacing;  // item之间间隔
@property (nonatomic, assign) UIEdgeInsets      edgeInsets;   // 四边间距
@property (nonatomic, assign) NSInteger         maxReuseCount;// 最大可重用cell数 默认2

// 从缓冲池获取cell
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

// 注册cell 以便自动重用
- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

// 滚动指定index位置
- (void)scrollToIndex:(NSInteger)index atPosition:(TYHorizenTableViewPosition)position animated:(BOOL)animated;

//  选中，取消选中 index项 cell
- (void)selectCellAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(TYHorizenTableViewPosition)position;

- (void)deSelectCellAtIndex:(NSInteger)index animated:(BOOL)animated;

// 获取index项cell,如果cell不可见返回nil
- (TYHorizenTableViewCell *)cellForIndex:(NSInteger)index;

// 获取当可见cells
- (NSArray *)visibleCells;;

// 重新读取数据
- (void)reloadData;

- (void)reloadItemAtIndex:(NSInteger)index;

- (void)reloadItemAtIndexSet:(NSIndexSet *)indexSet;

@end


